# doc-writing-test

Testing a toolchain for writing documents. The idea is to write a document in markdown, then compile it to whatever I want using Pandoc. The two applications I have in mind are writing papers and writing blog posts.

For writing papers, advantages over Overleaf are:

- Markdown results in cleaner source code than LaTeX (separate formatting from content)

For writing blog posts, advantages over compilation with Pelican are:

- I can use whatever macros and such that I want

## Commands

- Build Docker Image: `docker build -t doc-writing-test .`
- Open Interactive Docker Shell: `docker run -it doc-writing-test /bin/ash`
<!-- - Run Docker: `docker run -t doc-writing-test` -->
