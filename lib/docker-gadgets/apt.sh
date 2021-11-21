# @brief Interact with APT repositories.
thisdir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
. "${thisdir}/usage.sh"

keyring_root=/usr/share/keyrings
sources_root=/etc/apt/sources.list.d

# @description Install a Debian package from a url.
#
# @arg $1 str URL from which to download and install the Debian package.
#
# @exitcode 1 Invalid number of arguments.
install-deb-from-url() {
	if [[ "$#" -ne "1" ]]; then
		print-usage "<url>" ; return 1
	fi
	local url="$1"
	local deb="$(mktemp).deb"
	curl -SL "${url}" -o "${deb}"
	apt-get install -y -f "${deb}"
	rm "${deb}"
}

# @description Add the specified public key to a custom keyring.
#
# This function uses keyserver.ubuntu.com by default, since it seems the
# most reliable.
#
# @arg $1 str Base name (no extension) to use for the keyring file.
# @arg $2 str The ID or fingerprint of the key to fetch.
# @arg $3 str If present, the keyserver to use instead of the default.
#
# @exitcode 1 Invalid number of arguments.
add-key-from-id() {
	if [[ "$#" -ne "2" ]] && [[ "$#" -ne "3" ]]; then
		print-usage "<name>" "<key_id|fingerprint> [<keyserver>]"; return 1
	fi
	local name="$1"
	local key_id="$2"
	local keyring="${keyring_root}/${name}.gpg"
	local keyserver="${3:-keyserver.ubuntu.com}"
	gpg \
		--no-default-keyring \
		--keyring "${keyring}" \
		--keyserver "${keyserver}" \
		--recv-keys "${key_id}"
}

# @description Add the specified public key to a custom keyring.
#
# @arg $1 str Base name (no extension) to use for the keyring file.
# @arg $2 str URL from which to download the unarmored public key.
#
# @exitcode 1 Invalid number of arguments.
add-key-from-url() {
	if [[ "$#" -ne "2" ]]; then
		print-usage "<name>" "<url>"; return 1
	fi
	local name="$1"
	local url="$2"
	local keyring="${keyring_root}/${name}.gpg"
	curl -sSL "${url}" > "${keyring}"
}

# @description Add the specified public key to a custom keyring.
#
# @arg $1 str Base name (no extension) to use for the keyring file.
# @arg $2 str URL from which to download the armored public key.
#
# @exitcode 1 Invalid number of arguments.
add-armored-key-from-url() {
	if [[ "$#" -ne "2" ]]; then
		print-usage "<name>" "<url>"; return 1
	fi
	local name="$1"
	local url="$2"
	local keyring="${keyring_root}/${name}.gpg"
	curl -sSL "${url}" | gpg --dearmor > "${keyring}"
}

# @description Add a repo with the specified keyring.
#
# @arg $1 str Base name (no extension) for the keyring file and sources list.
# @arg $2 str URI of the APT repo for the source entry; see sources.list(5).
# @arg $3.. str Args for the source entry; see sources.list(5).
#
# @exitcode 1 Too few arguments.
add-signed-source() {
	if [[ "$#" -lt "2" ]]; then
		print-usage "<name>" "<repo_uri>" "[<arg1>[, arg2[,...]]"; return 1
	fi
	local name="$1"
	local repo_uri="$2"
	local keyring="${keyring_root}/${name}.gpg"
	if [[ ! -f "${keyring}" ]]; then
		(>&2 echo "Specified keyring does not exist or is not a file: ${keyring}")
		return 2
	fi
	shift 2
	local sources_list="${sources_root}/${name}.list"
	echo deb "[signed-by=${keyring}]" "${repo_uri}" "$@" | tee "${sources_list}"
}

# @description Add a repo with release codename as the first sources.list arg.
#
# @arg $1 str Base name (no extension) for the keyring file and sources list.
# @arg $2 str URI of the APT repo for the source entry; see sources.list(5).
# @arg $3.. str Args for the sources.list entry; see sources.list(5).
#
# @exitcode 1 Too few arguments.
add-signed-source-lsb() {
	if [[ "$#" -lt "2" ]]; then
		print-usage "<name>" "<repo_uri>" "[<arg1>[, arg2[,...]]"; return 1
	fi
	local name="$1"
	local repo_uri="$2"
	shift 2
	add-signed-source "${name}" "${repo_uri}" "$(lsb_release -sc)" "$@"
}
