Object.assign(tus.defaultOptions, {
  endpoint: '/files/',
  retryDelays: [0, 1000, 3000, 6000, 9000],
});

document.querySelectorAll('input[type=file]').forEach(fileInput => {
  fileInput.addEventListener('change', () => {
    for (var i = 0; i < fileInput.files.length; i++) {
      var file = fileInput.files[i],
          progressBar = document.querySelector('.progress').cloneNode(true);

      fileInput.parentNode.insertBefore(progressBar, fileInput);

      const upload = new tus.Upload(file, {
        metadata: {
          'filename':     file.name, // for 'Content-Type'
          'content_type': file.type, // for 'Content-Disposition'
        },
      });

      upload.options.onProgress = (bytesSent, bytesTotal) => {
        const progress = parseInt(bytesSent / bytesTotal * 100, 10);
        const percentage = progress.toString() + '%';
        progressBar.querySelector('.progress-bar').style = 'width: ' + percentage;
        progressBar.querySelector('.progress-bar').innerHTML = percentage;
      };

      upload.options.onSuccess = result => {
        fileInput.parentNode.removeChild(progressBar);

        // custruct uploaded file data in the Shrine attachment format
        const fileData = {
          id: upload.url,
          storage: 'cache',
          metadata: {
            filename:  file.name.match(/[^\/\\]+$/)[0], // IE returns full path
            size:      file.size,
            mime_type: file.type,
          }
        };

        // assign file data to the hidden field so that it's submitted to the app
        var hiddenInput = fileInput.parentNode.querySelector('input[type=hidden]');
        hiddenInput.value = JSON.stringify(fileData);

        urlElement = document.createElement('p');
        urlElement.innerHTML = upload.url;
        fileInput.parentNode.insertBefore(urlElement, fileInput.nextSibling);
      };

      upload.options.onError = error => {
        if (error.originalRequest.status == 0) { // no internet connection
          setTimeout(() => { 
            upload.start();
          }, 5000);
        } else {
          console.error(error);
        }
      };

      // start the tus upload
      upload.start();
    };

    // remove selected files
    fileInput.value = '';
  });
});

window.App || (window.App = {});

$(document).ready(function() {
  App.templates || (App.templates = {
    video: $('#video-template').html(),
    movie: $('#movie-template').html()
  });

  Handlebars.registerPartial('videoTemplate', App.templates.video);

  App.compilers || (App.compilers = {
    movie: Handlebars.compile(App.templates.movie),
    video: Handlebars.compile(App.templates.video)
  });

  const moviesEl = $('ul#movies');

  if (moviesEl.length) {
    MessageBus.start();
    MessageBus.callbackInterval = 500;
    MessageBus.subscribe('/movies', data => {
      const movieEl = $('#movie-' + data.id + '>.panel-body');

      if (movieEl.length) {
        movieEl.html(App.compilers.video(data));
      }else{
        moviesEl.append(App.compilers.movie(data));
      }
    });
  };
});
