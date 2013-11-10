Action
======

The only thing persons can do in the game are actions.

They live in a little menu that changes based on the context.

Clicking on them makes them happen.

    module.exports = (I={}) ->
      self = {}

      Object.defaults self, I,
        name: "Action"
        icon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABEklEQVQ4T2NkoBAwUqifYYgZ4Dfdbffdl0+9rzZc/QXzOklecJ9g//3nt19PDlQdV0UxoPh4+n+QwN/ffxn+/P7D8PvXH4ZfP38z/PoBwr8YfgIxiJYUkmT49es3w41bNy+d7bqsD9IDdgHIACthW4a//4AG/PsDx7///mX4/fc3w+9/QPwXKA7EIPrc+bMMN67fPnVz5h1zsAEFh1L+W4haIzSDFAINgmgG0n+gBoAMBxlw7jzDzeu3j96b99AGbEDO3oT/uJz98zvEC1wcXAySklIMr1+9Zrh1/c6Fe/MfGsK9QExi0svVtPj569f+37//Pro374E6WbGgnKiw4+6XB34MqxnIi0ZsLiUpHQxOAwDhLLkRWHt4RAAAAABJRU5ErkJggg=="

      return self
