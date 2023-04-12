#!/bin/sh

# Almost all of the code is from:
#   https://github.com/tetutaro/dotfiles/tree/main/fonts
# Rationale explained (in Japanese) at:
#   https://qiita.com/tetutaro/items/f895a2ecb1360206aaba

PREFIX="$( dirname $( realpath "$0" ) )"

CHARS_TO_LEAVE_UNTOUCHED_FROM_RICTY="${1}"

PYTHON="/usr/bin/python3"
OUTPUT_DPATH="/output"

# From: https://mix-mplus-ipa.osdn.jp/migu/
MIGU_VERSION="20200307"
# From: https://github.com/google/fonts/tree/main/ofl/inconsolata/static
INCONSOLATA_VERSION="dc601f440c1332bf93dc0eb87f81a8748a68d565"

PATCH_TILDE_WITH_IBM_PLEX="false"
PATCH_NERD_FONTS="true"

TMP_DPATH="$( mktemp -d )"

_download() {
    SOURCE="$1"
    OUTPUT="$2"

    echo "Downloading ${OUTPUT}"
    curl -sL -o "${OUTPUT}" "${SOURCE}"
}

# Ricty Generator
_download \
    https://rictyfonts.github.io/files/ricty_generator.sh \
    ${TMP_DPATH}/ricty_generator.sh
patch ${TMP_DPATH}/ricty_generator.sh < ${PREFIX}/fix_zero.patch
patch ${TMP_DPATH}/ricty_generator.sh < ${PREFIX}/fix_backquote.patch

# OS/2 Version Reviser
_download \
    https://rictyfonts.github.io/files/os2version_reviser.sh \
    ${TMP_DPATH}/os2version_reviser.sh
# Inconsolata Regular
_download \
    https://github.com/google/fonts/blob/${INCONSOLATA_VERSION}/ofl/inconsolata/static/Inconsolata-Regular.ttf?raw=true \
    ${TMP_DPATH}/Inconsolata-Regular.ttf
# Inconsolata Bold
_download \
    https://github.com/google/fonts/blob/${INCONSOLATA_VERSION}/ofl/inconsolata/static/Inconsolata-Bold.ttf?raw=true \
    ${TMP_DPATH}/Inconsolata-Bold.ttf
# Migu 1M (download and extract)
_download \
    https://osdn.net/projects/mix-mplus-ipa/downloads/72511/migu-1m-${MIGU_VERSION}.zip \
    ${TMP_DPATH}/migu-1m.zip \
    && unzip -d ${TMP_DPATH}/migu-1m ${TMP_DPATH}/migu-1m.zip 1>/dev/null \
    && mv -f ${TMP_DPATH}/migu-1m/*/migu-1m-*.ttf ${TMP_DPATH} \
    && rm -rf ${TMP_DPATH}/migu-1m/ ${TMP_DPATH}/migu-1m.zip

# Generate Ricty
cd ${TMP_DPATH} \
    && sh ./ricty_generator.sh \
        -d "${CHARS_TO_LEAVE_UNTOUCHED_FROM_RICTY}" \
        Inconsolata-Regular.ttf \
        Inconsolata-Bold.ttf \
        migu-1m-regular.ttf \
        migu-1m-bold.ttf

if [[ -z "$( ls ${TMP_DPATH}/Ricty*.ttf 2>/dev/null )" ]]; then
    echo "Failed to generate Ricty" >&2
    exit 1
fi

for fpath in ${TMP_DPATH}/Ricty*.ttf; do
    sh ${TMP_DPATH}/os2version_reviser.sh ${fpath}
done

# Patch tilde
if $PATCH_TILDE_WITH_IBM_PLEX; then
    # IBM Plex Mono for Ricty Discord
    _download \
        https://github.com/IBM/plex/raw/master/IBM-Plex-Mono/fonts/complete/ttf/IBMPlexMono-Bold.ttf \
        ${TMP_DPATH}/IBMPlexMono-Bold.ttf
    _download \
        https://github.com/IBM/plex/raw/master/IBM-Plex-Mono/fonts/complete/ttf/IBMPlexMono-BoldItalic.ttf \
        ${TMP_DPATH}IBMPlexMono-BoldItalic.ttf
    _download \
        https://github.com/IBM/plex/raw/master/IBM-Plex-Mono/fonts/complete/ttf/IBMPlexMono-Italic.ttf \
        ${TMP_DPATH}IBMPlexMono-Italic.ttf
    _download \
        https://github.com/IBM/plex/raw/master/IBM-Plex-Mono/fonts/complete/ttf/IBMPlexMono-Regular.ttf \
        ${TMP_DPATH}IBMPlexMono-Regular.ttf

    cd ${TMP_DPATH} && \
        sh ${PREFIX}/ricty_discord_patcher.sh
fi

# Rename TTYname of Ricty
for fpath in ${TMP_DPATH}/Ricty*.ttf; do
    ${PYTHON} "${PREFIX}/rename_ricty.py" "${fpath}" "${OUTPUT_DPATH}"
    rm ${fpath}
done

# Patch Nerd Fonts to Ricty
if $PATCH_NERD_FONTS; then
    if [[ ! -d ${TMP_DPATH}/nerd-fonts ]]; then
        git clone --depth=1 https://github.com/ryanoasis/nerd-fonts ${TMP_DPATH}/nerd-fonts
    fi
    for fpath in ${OUTPUT_DPATH}/Ricty*.ttf; do
        ${PYTHON} \
            ${TMP_DPATH}/nerd-fonts/font-patcher \
            --quiet \
            --fontawesome \
            --fontawesomeextension \
            --fontlinux \
            --octicons \
            --powersymbols \
            --powerline \
            --powerlineextra \
            --material \
            --weather \
            --adjust-line-height \
            --outputdir="${TMP_DPATH}" \
            "${fpath}" \
        && rm ${fpath}
    done
    for fpath in ${TMP_DPATH}/Ricty*.ttf; do
        ${PYTHON} "${PREFIX}/rename_ricty.py" "${fpath}" "${OUTPUT_DPATH}"
    done
fi
