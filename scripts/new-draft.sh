#!/bin/sh
# 音声ダンプ用の空ファイルを drafts/raw/ に作る．
#
#   new-draft.sh              -> drafts/raw/2026-09-18.md
#   new-draft.sh zure         -> drafts/raw/2026-09-18_zure.md
#   new-draft.sh zure hearing -> drafts/raw/2026-09-18_zure_hearing.md
#   new-draft.sh 980 -d 2026-09-20
#
# 同名のファイルがある場合は 2026-09-18_zure2.md のように連番を足す．
# 既存ファイルは絶対に上書きしない．
set -eu

usage() {
    cat <<'EOS'
使い方: new-draft.sh [チャネル] [追加サフィックス...] [-d YYYY-MM-DD] [-o]

  チャネル      zure / 980 / 500 / substack / free など．省略可
  -d, --date    日付を指定する．省略時は今日
  -o, --open    作成後に VS Code で開く
  -h, --help    このヘルプ

作ったファイルのパスを標準出力に出す．
EOS
}

date_str=$(date +%Y-%m-%d)
suffix=''
open_after=0

while [ $# -gt 0 ]; do
    case "$1" in
        -d | --date)
            shift
            date_str="${1:-}"
            ;;
        -o | --open) open_after=1 ;;
        -h | --help)
            usage
            exit 0
            ;;
        -*)
            echo "new-draft.sh: 知らないオプション: $1" >&2
            usage >&2
            exit 2
            ;;
        *) suffix="${suffix}_$1" ;;
    esac
    shift
done

case "$date_str" in
    [0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]) ;;
    *)
        echo "new-draft.sh: 日付は YYYY-MM-DD の形で指定する: '$date_str'" >&2
        exit 2
        ;;
esac

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
drafts_dir="${MBW_DRAFTS_DIR:-$script_dir/../drafts/raw}"
mkdir -p "$drafts_dir"

base="${date_str}${suffix}"
path="$drafts_dir/$base.md"
n=2
while [ -e "$path" ]; do
    path="$drafts_dir/$base$n.md"
    n=$((n + 1))
done

# noclobber を有効にして，万一の競合でも既存ファイルを潰さない
set -C
: >"$path"
set +C

echo "$path"

if [ "$open_after" -eq 1 ]; then
    if command -v code >/dev/null 2>&1; then
        code "$path"
    else
        echo "new-draft.sh: code コマンドが見つからないので開けなかった" >&2
    fi
fi
