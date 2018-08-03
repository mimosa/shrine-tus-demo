web: bundle exec puma -C config/puma.rb
job: bundle exec sidekiq -r ./*.rb  -C config/sidekiq.yml
tus: tusd --hooks-http http://localhost:$PUMA_PORT/write --hooks-http-retry 5 --hooks-http-backoff 2 -host localhost -port $TUSD_PORT -behind-proxy >> log/$RACK_ENV.log
ws:  sleep 2 && anycable-go -log -addr=localhost:9293
