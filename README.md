# Crema-Christmas Game
This is an experiment for spreading Holiday Cheer at [Cremalab](http://cremalab.com). It's an entirely client-side Javascript application, written in CoffeeScript and compiled with Brunch. It's basically DOM elements moving around a page with CSS transforms cleverly disguised as a game. Multiplayer is made possible by [PubNub](http://www.pubnub.com)'s stellar realtime messaging service.

## Superstars
* Avatar design and markup by [@dmdez](https://github.com/dmdez) and [@roblafeve](https://github.com/roblafeve)
* Disco and Moonwalk modes by [@dmdez](https://github.com/dmdez)
* UI Design, CSS magic, and front-end magic by [@roblafeve](https://github.com/roblafeve)
* Map design and implementation by [@MattBishop2](https://github.com/MattBishop2)
* Game engine by [@albatrocity](https://github.com/albatrocity)

## Tech
* [Brunch](http://brunch.io) is the build tool
* [PubNub](http://www.pubnub.com) is facilitates all real-time messaging and presence-detection.
* [Exoskeleton](http://exosjs.com) is a lightweight [Backbone](http://backbonejs.org) replacement. Backbone models are used as the source of truth for player attributes.
* [Backbone NativeView](https://github.com/akre54/Backbone.NativeView) for jQuery-less view management
* A few classes borrowed from [Chaplin](https://github.com/akre54/Backbone.NativeView), an awesome Backbone application framework. Most notably the [Event Broker](https://github.com/chaplinjs/chaplin/blob/master/src/chaplin/lib/event_broker.coffee), [Mediator](https://github.com/chaplinjs/chaplin/blob/master/src/chaplin/mediator.coffee), and [CollectionView](https://github.com/chaplinjs/chaplin/blob/master/src/chaplin/views/collection_view.coffee)
* [SVG Injector](https://github.com/iconic/SVGInjector) - lets us be lazy and just drop in image tags but still use all of the SVG JavaScript stuff.
* [ImagesLoaded](https://github.com/desandro/imagesloaded) because sometimes you just gotta know when an images is loaded.


## Development
*Please use your own PubNub keys!* PubNub's sandbox dev plan is free and awesome. Keys are set at `app/lib/notifier.coffee:11`.

* `npm install brunch -g`
* `npm install`
* `bower install`
* `npm start`

## High-level module definitions
### GameController
This is where the game is instantiated, the map is set up, and a player is created. There are some experimental features still hanging around in there.

### Notifier
This is the singleton that is responsible for communicating with PubNub. It communicates with all other modules via the `Mediator`'s `publishEvent` and `subscribeEvent` methods.

### Escort
Iterates through PubNub channels and finds one occupied by less than the set room capacity. If a room is full, it will escort you to a new one. Cute, right? No? Okay.

### ChatterBox
Instantiated with each Avatar and is responsible for rendering all chat input views and speech bubbles, as well as tell the `Notifier` when somebody said something.

### AutoPilot
An AutoPilot is created for each Avatar by the GameController and accepts the avatar instance and the map view as arguements. It is responsible for moving an Avatar to a position on tap. Stop me if these class names are getting too cutesy.

### Landscaper
Takes an array of obstructions (see `lib/landscape.coffee`), creates their images or SVGs, figures our their size, places them on the map, and does collision and proximity detection for the active player. The `MapView` runs all requested movements through the `Landscaper` to get the okay. Sometimes the `Landscaper` is like "whoa man, you can't move there, that's a wall" but sometimes it's like "yeah, go right ahead, I'm cool with that!"

### Activist
When creating map obstructions, the `Landscaper` passes off any obstruction that has interactivity off to the `Activist`, who won't shut up about what it thinks. It brings obstructions to life by adding event listeners to them. This is probably one of the least clever class names.

### Reactor
This is just a boring class that allows landscape events to have a little better game-wide context. It executes functions in its supplied `lib/actions.coffee` file. I don't think this class ever thinks for itself. What a plebe.

### Navi
I told you to stop me. Yes, this is a Zelda reference. Its functionality could have existed in any other class. Honestly, it does the simplest thing. But I wanted a Zelda reference. Navi is responsible for rendering `HintView`s. It's usually called from obstruction events with `EventBroker.publishEvent 'navi:hint'`

### TrailBlazer
Currently unused classed that takes Avatar movements and draws on a canvas. This game used to be set outside and you could draw trails in the snow, but people's computers started to catch on fire so we took it out.

