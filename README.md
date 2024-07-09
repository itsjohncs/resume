# Resume

[My resume](https://resume.johncs.com) ([PDF](https://resume.johncs.com/resume.pdf)) is created from a one-file HTML page in this repo.

I have several scripts in `scripts/` that help out:

* `install-git-hooks.sh`: Installs the Git hooks for the repo. Run once after cloning.
    * `pre-commit`: Checks that lint and prettify has been run and that the PDF is up-to-date (does not overwrite anything). Will also run `wording-check.sh` without `--broad`.
* `create-pdf.sh`: Creates `resume.pdf` using headless Chrome.
* `lint-and-prettify.sh`: Lints and prettifies the scripts and HTML.
* `wording-check.sh`: Sends the resume to ChatGPT for spell checking and grammar. Pass the script `--broad` to get broader, more general advice.

When I'm working on my resume, I will use my [serve](https://github.com/itsjohncs/dotfiles/blob/main/src/scripts/serve) utility to give me a live-reloading web server.
