FROM ruby:2.6.2

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY install_rclone.sh ./
RUN bash ./install_rclone.sh

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

COPY . .

#RUN mkdir -p ./tmp

ENTRYPOINT ["./docker-start.sh"]
