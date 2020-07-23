FROM ruby:2.6.6
RUN apt-get update -qq && apt-get upgrade -y
RUN apt-get clean
RUN apt-get install -y build-essential nodejs openssh-server && apt-get clean
RUN gem install foreman

RUN mkdir /var/run/sshd
RUN echo 'root:2181e4dbe685d57594bc6abffadb5d6c0c0af5eb9d7878d318122a25e5305ea3' | chpasswd

RUN mkdir ~/.ssh
RUN touch ~/.ssh/authorized_keys
RUN echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCM6+ZFvX+Bk6/QPiRXSIQBJ0QzR/0lDMdHj2UrmM+qKjWGfr1OhPZpMqdso/hKpdQOaYPQGcYKKgasBwmEUYgtNtHv5U2p1Ey1OM+7Nasz2+k19qEW/+ynVnyJd0TPERr5oyEe2VIX2HJcFuD/Exx+y2oAa8ZkCzli0b1g4Ixp87azxhoEfWJSSDaC2wMvx3dP52cCLWFclE8HQ8R46f1rrRgh3gkTpdHSEtJP6M8EcmQCL9BNs/AYLiH/jL8X6zDctzs+SzrpETbV//Jn5/d1g/hrlmZyl3c5K2cGZ3evb7hNNrSYmwbUEG3hxtNTg4/kq2nhWLy8NtWzBqPWQXM0PHB1eMrJmh6YKddrhzTo7kxnlYKi9UpWp4+xZKvs4UztsDWNJmWdWNSWfaCXLLAqtODFVqnzPY/Es5p6y2PcJ3aSZ+L0/qPG7i7ukC3lI8tf5D8R8OZ56UDT6Q2K6I9ex93XbLa9BvWp6+qzBQSGKUh9+1fXe9RpWI2MOzUg38tQUkExcsF3CuD+AlNmV+AVJrJZZoxJCthlK1wkNkR8qY/3GqyhMlyxxywQai5h98Iq9skhHrcsfPV6IKYV2+1cF9fq6WV/FQ4JyZEeOy93rr1QKWHofe+W0zGIzSrq1xPQk0a8soboIovF9jGbjQPIyPHGE/L+FAqt7ETZ3Okmw==' >>  ~/.ssh/authorized_keys
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

ENV GOVUK_APP_NAME frontend
ENV PORT 3005
ENV RAILS_ENV development

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
ADD .ruby-version $APP_HOME/
RUN bundle install

ADD . $APP_HOME

RUN GOVUK_WEBSITE_ROOT=https://www.gov.uk GOVUK_APP_DOMAIN=www.gov.uk RAILS_ENV=production bundle exec rails assets:precompile

HEALTHCHECK CMD curl --silent --fail localhost:$PORT || exit 1

CMD ["/usr/sbin/sshd", "-D"]
