Animation Event
===============

Holds info relevant to displaying the result of player action or map effects.

Ideally will log to the messages, scroll to the location, perform any animations
(shooting, exploding, death, etc.)

Many events may be placed in a queue.

The queue will be run through to display them all visually and textually to the
player.

Messages in the log will be linked to the event so you can scroll back to where
it happened.

    module.exports = (I={}, self=Core(I)) ->
      Object.defaults I,
        duration: 300 #ms
        position: null
        message: null

      self.attrAccessor "duration", "position", "message"

      return self
