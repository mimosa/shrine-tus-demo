web: bundle exec puma -C config/puma.rb
tus: tusd -host localhost -port $TUSD_PORT -behind-proxy >> log/$RACK_ENV.log &
