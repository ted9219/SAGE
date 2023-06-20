# use R 4.1.2 as a base image
FROM rocker/rstudio:4.1.2
MAINTAINER Subin Kim <jg051623@yuhs.ac>

# install java develop kit and rJava
RUN apt-get update && \
    apt-get install -y default-jdk
RUN R CMD javareconf
RUN R -e "install.packages('rJava', dependencies = TRUE)"

# install devtools
RUN apt-get update
RUN apt-get install -y \
    build-essential \ 
    libcurl4-gnutls-dev \
    libxml2-dev \
    libssl-dev \
    libgit2-dev \
# install other
    libfontconfig1-dev \
    libcairo2-dev \
    libsodium-dev

RUN R -e "install.packages('devtools')"
RUN R -e "install.packages('dplyr')"
RUN R -e "install.packages('data.table')"
RUN R -e "install.packages('R.utils')"
RUN R -e "install.packages('rvg')"

# install additional packages
RUN R -e "install.packages('renv')"
RUN R -e "install.packages('lubridate')"

RUN R -e 'devtools::install_github("OHDSI/DatabaseConnector",ref="v5.0.2")'
RUN R -e 'devtools::install_github("OHDSI/ParallelLogger",ref="v2.0.2")'

# install JDBC driver
RUN mkdir -p /home/rstudio/temp
RUN mkdir -p /home/rstudio/jdbc
ADD analysis /home/rstudio/analysis
RUN mkdir -p /home/rstudio/result

RUN R -e "DatabaseConnector::downloadJdbcDrivers(dbms = 'postgresql',pathToDriver = '/home/rstudio/jdbc')"
RUN R -e "DatabaseConnector::downloadJdbcDrivers(dbms = 'redshift',pathToDriver = '/home/rstudio/jdbc')"
RUN R -e "DatabaseConnector::downloadJdbcDrivers(dbms = 'sql server',pathToDriver = '/home/rstudio/jdbc')"
RUN R -e "DatabaseConnector::downloadJdbcDrivers(dbms = 'oracle',pathToDriver = '/home/rstudio/jdbc')"
RUN R -e "DatabaseConnector::downloadJdbcDrivers(dbms = 'spark',pathToDriver = '/home/rstudio/jdbc')"

RUN R -e "setwd('/home/rstudio/analysis'); devtools::install()"
