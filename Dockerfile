FROM rstudio/plumber

COPY calculos_fin_FGL.R /

EXPOSE 8000/tcp

CMD ["R/calculos_fin_FGL.R"]