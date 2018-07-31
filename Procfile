web: bundle exec puma -C config/puma.rb
job: bundle exec sidekiq -r ./*.rb  -C config/sidekiq.yml
tus: tusd -host localhost -port $TUSD_PORT -behind-proxy >> log/$RACK_ENV.log &
