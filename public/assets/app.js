// This code uses:
//
// * babel-polyfill (https://babeljs.io/docs/usage/polyfill/)
// * tus-js-client (https://github.com/tus/tus-js-client)
// * uppy (https://uppy.io)

document.querySelectorAll('input[type=file]').forEach(fileInput => {
  fileInput.style.display = 'none' // uppy will add its own file input

  const uppy = Uppy.Core({
      id: fileInput.id,
      restrictions: {
        minNumberOfFiles: 1,
        maxNumberOfFiles: 9,
        allowedFileTypes: ['image/gif', 'video/*']
      }
    })
    .use(Uppy.FileInput, {
      target: fileInput.parentNode,
    })
    .use(Uppy.Tus, {
      endpoint: '//localhost:3000/files/',
        chunkSize: 5 * 1024 * 1024,
        retryDelays: [0, 1000, 3000, 6000, 9000],
    })
    .use(Uppy.ProgressBar, {
      target: fileInput.parentNode,
    });

  uppy.run();

  uppy.on('upload-success', (file, data) => {
    const uploadedFileData = JSON.stringify({
      id: data.url,
      storage: "cache",
      metadata: {
        filename: file.name,
        size: file.size,
        mime_type: file.type,
      }
    })

    const hiddenInput = document.getElementById(fileInput.dataset.uploadResultElement)
    hiddenInput.value = uploadedFileData

    const videoLink = document.getElementById(fileInput.dataset.previewElement)
    videoLink.href = data.url
    videoLink.innerHTML = data.url
  })
});

window.App || (window.App = {});

$(document).ready(() => {
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
    App.cable = ActionCable.createConsumer('ws://localhost:5300/cable');
    App.currentChannel = App.cable.subscriptions.create({
          channel: 'notifications',
          id: 'test'
        }, {
      received: data => {
        const movie = data.movie;
        const movieEl = $('#movie-' + movie.id + '>.panel-body');
        if (movieEl.length) {
          movieEl.html(App.compilers.video(movie));
        }else{
          moviesEl.append(App.compilers.movie(movie));
        }
      }
    });
  };
});
