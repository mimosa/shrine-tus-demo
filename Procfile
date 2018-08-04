web: bundle exec puma -C config/puma.rb
job: bundle exec sidekiq -r ./*.rb  -C config/sidekiq.yml
tus: tusd --hooks-http http://localhost:$PUMA_PORT/write --hooks-http-retry 5 --hooks-http-backoff 2 -host localhost -port $TUSD_PORT -behind-proxy >> log/$RACK_ENV.log
rpc: bundle exec ./anycable
ws:  sleep 2 && anycable-go -log=true -addr=localhost:9293 -redis=redis://localhost:6380/15
