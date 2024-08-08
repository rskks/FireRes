Shiny.addCustomMessageHandler("switchMode", function(message) {
  document.body.classList.remove(message.remove);
  document.body.classList.add(message.add);
});
