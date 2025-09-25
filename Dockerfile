FROM ubuntu:latest
WORKDIR /app
COPY .  /app
RUN  apt-get update && apt-get install -y fortune-mod cowsay netcat-openbsd && rm -rf /var/lib/apt/lists/*
RUN  chmod +x /app/wisecow.sh
ENV PATH="/usr/games:${PATH}"   
EXPOSE 4499
CMD ["bash", "wisecow.sh"]
