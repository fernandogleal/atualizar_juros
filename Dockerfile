# Use an official R runtime as a parent image
FROM rstudio/plumber

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install Ubuntu packages
RUN apt-get update && apt-get install -y \
  libssl-dev \
  libcurl4-openssl-dev \
  libxml2-dev

# Install R packages
RUN R -e "install.packages(c('httr', 'dplyr', 'lubridate', 'glue'), repos='http://cran.rstudio.com/')"

# Copy the R script into the Docker image
COPY calculos_fin_FGL.R /

# Make port 8000 available to the world outside this container
EXPOSE 8000/tcp

# Run calculos_fin_FGL.R when the container launches
CMD ["/calculos_fin_FGL.R"]