FROM rocker/rstudio:4.3.2

RUN apt-get update && apt-get install -y --no-install-recommends \
    libglpk40 \
    libglpk-dev \
    libxml2-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/rstudio/.config/rstudio/themes && \
    wget -O /home/rstudio/.config/rstudio/themes/Dracula.rstheme \
    https://raw.githubusercontent.com/dracula/rstudio/master/dracula.rstheme && \
    chown -R rstudio:rstudio /home/rstudio/.config
    RUN R -e "install.packages(c('igraph','ggraph','tidygraph','pheatmap','tidyverse', 'janitor'), repos='https://cloud.r-project.org')"