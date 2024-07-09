# Resume

This is the source for my resume ([resume.johncs.com](https://resume.johncs.com)).

It's built as a simple one-file HTML page with some basic scripts to help me:

* `install-git-hooks.sh`: Installs the Git hooks for the repo. Run once after cloning.
* `create-pdf.sh`: Creates `resume.pdf` using headless chrome.
* `lint-and-prettify.sh`: Lints and prettifies the scripts and HTML.
* `wording-check.sh`: Sends the resume to ChatGPT for spell checking and grammar. Pass the script `--broad` to get broader, more general advice.
