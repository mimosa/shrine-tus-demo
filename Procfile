web: bundle exec puma -t 5:5 -p $PUMA_PORT -e $RACK_ENV
tus: tusd -port $TUSD_PORT -behind-proxy -s3-bucket $S3_BUCKET -s3-endpoint $S3_ENDPOINT