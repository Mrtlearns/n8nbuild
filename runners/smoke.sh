#!/bin/sh
# CI smoke test, run INSIDE the built image:  docker run --rm --entrypoint sh -v "$PWD/runners:/ci:ro" <image> /ci/smoke.sh <N8N_VERSION>
set -eu
WANT="${1:-}"
cd /opt/runners/task-runner-javascript
node -e '
const {PDFDocument,StandardFonts}=require("pdf-lib");
(async()=>{const d=await PDFDocument.create();const p=d.addPage([300,200]);const f=await d.embedFont(StandardFonts.Helvetica);
p.drawText("ci smoke",{x:20,y:100,font:f,size:14});const b=await d.save();require("fs").writeFileSync("/tmp/t.pdf",b);
const n=(await PDFDocument.load(b)).getPageCount(); if(n!==1) throw new Error("pages="+n); console.log("pdf-lib ok bytes",b.length,"pages",n)})().catch(e=>{console.error(e);process.exit(1)})'
for m in @pdf-lib/fontkit uuid date-fns lodash axios; do node -e "require('$m')"; echo "js $m ok"; done
/opt/runners/task-runner-python/.venv/bin/python -c '
import pypdf,pikepdf,requests,bs4,pydantic,ocrmypdf
r=pypdf.PdfReader("/tmp/t.pdf"); assert len(r.pages)==1, len(r.pages)
print("python ok: pypdf pages",len(r.pages),"text:",r.pages[0].extract_text().strip(),"| pikepdf",pikepdf.__version__,"| ocrmypdf",ocrmypdf.__version__)'
qpdf --version | head -1; gs --version; tesseract --version 2>&1 | head -1; magick -version | head -1; command -v unpaper
if command -v apk >/dev/null 2>&1; then echo "FAIL: apk binary present"; exit 1; fi; echo "apk absent (good)"
cmp /etc/n8n-task-runners.json /ci/n8n-task-runners.json && echo "runner json == repo copy"
/opt/runners/task-runner-python/.venv/bin/python -m json.tool /etc/n8n-task-runners.json >/dev/null && echo "runner json valid"
if [ -n "$WANT" ]; then
  GOT=$(node -p 'require("/opt/runners/task-runner-javascript/package.json").version')
  echo "js runner package version: $GOT (want $WANT)"; [ "$GOT" = "$WANT" ] || { echo "FAIL: runner version mismatch"; exit 1; }
fi
id
echo SMOKE_OK
