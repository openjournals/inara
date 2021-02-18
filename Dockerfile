FROM pandoc/latex:2.11.4

# Install additional LaTeX packages
RUN tlmgr update --self && tlmgr install \
  algorithmicx \
  algorithms \
  booktabs \
  caption \
  collection-xetex \
  environ \
  etoolbox \
  fancyvrb \
  float \
  fontspec \
  latexmk \
  listings \
  logreq \
  marginnote \
  mathspec \
  pgf \
  preprint \
  seqsplit \
  tcolorbox \
  titlesec \
  trimspaces \
  xcolor \
  xkeyval \
  xstring

# Copy templates, images, and other resources
ARG openjournals_path=/usr/local/share/openjournals
COPY ./resources $openjournals_path
COPY ./filters $openjournals_path/filters
COPY ./scripts/entrypoint.sh /usr/local/bin/inara

ENV JOURNAL=joss
ENV OPENJOURNALS_PATH=$openjournals_path

# Input is read from `paper.md` by default, but can be overridden. Output is
# written to `paper.pdf`
ENTRYPOINT ["/usr/local/bin/inara"]
CMD ["paper.md"]
