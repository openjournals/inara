FROM pandoc/latex:3.1.1-alpine

RUN apk add --no-cache ttf-hack

# Install additional LaTeX packages
RUN tlmgr update --self && tlmgr install \
  algorithmicx \
  algorithms \
  booktabs \
  caption \
  collection-context \
  draftwatermark \
  environ \
  etoolbox \
  fancyvrb \
  float \
  fontspec \
  fontsetup \
  hyperxmp \
  ifmtarg \
  latexmk \
  lineno \
  listings \
  luacode \
  lualatex-math \
  logreq \
  marginnote \
  mathspec \
  newcomputermodern \
  orcidlink \
  pgf \
  preprint \
  selnolig \
  seqsplit \
  soul \
  tcolorbox \
  titlesec \
  trimspaces \
  xcolor \
  xkeyval \
  xstring


ENV OSFONTDIR=/usr/share/fonts

COPY ./fonts/libre-franklin $OSFONTDIR/libre-franklin

RUN TERM=dumb luaotfload-tool --update \
  && chmod -R o+w /opt/texlive/texdir/texmf-var \
  && apk add --no-cache ttf-opensans \
  && fc-cache -sfv $OSFONTDIR/libre-franklin \
  && mtxrun --generate \
  && mtxrun --script font --reload

# Copy templates, images, and other resources
ARG openjournals_path=/usr/local/share/openjournals
COPY ./resources $openjournals_path
COPY ./data $openjournals_path/data
COPY ./scripts/clean-metadata.lua $openjournals_path
COPY ./scripts/entrypoint.sh /usr/local/bin/inara

ENV JOURNAL=joss
ENV OPENJOURNALS_PATH=$openjournals_path

# Input is read from `paper.md` by default, but can be overridden. Output is
# written to `paper.pdf`
ENTRYPOINT ["/usr/local/bin/inara"]
CMD ["paper.md"]
