(function(/*! Brunch !*/) {
  'use strict';

  var globals = typeof window !== 'undefined' ? window : global;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};

  var has = function(object, name) {
    return ({}).hasOwnProperty.call(object, name);
  };

  var expand = function(root, name) {
    var results = [], parts, part;
    if (/^\.\.?(\/|$)/.test(name)) {
      parts = [root, name].join('/').split('/');
    } else {
      parts = name.split('/');
    }
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function(name) {
      var dir = dirname(path);
      var absolute = expand(dir, name);
      return globals.require(absolute, path);
    };
  };

  var initModule = function(name, definition) {
    var module = {id: name, exports: {}};
    cache[name] = module;
    definition(module.exports, localRequire(name), module);
    return module.exports;
  };

  var require = function(name, loaderPath) {
    var path = expand(name, '.');
    if (loaderPath == null) loaderPath = '/';

    if (has(cache, path)) return cache[path].exports;
    if (has(modules, path)) return initModule(path, modules[path]);

    var dirIndex = expand(path, './index');
    if (has(cache, dirIndex)) return cache[dirIndex].exports;
    if (has(modules, dirIndex)) return initModule(dirIndex, modules[dirIndex]);

    throw new Error('Cannot find module "' + name + '" from '+ '"' + loaderPath + '"');
  };

  var define = function(bundle, fn) {
    if (typeof bundle === 'object') {
      for (var key in bundle) {
        if (has(bundle, key)) {
          modules[key] = bundle[key];
        }
      }
    } else {
      modules[bundle] = fn;
    }
  };

  var list = function() {
    var result = [];
    for (var item in modules) {
      if (has(modules, item)) {
        result.push(item);
      }
    }
    return result;
  };

  globals.require = require;
  globals.require.define = define;
  globals.require.register = define;
  globals.require.list = list;
  globals.require.brunch = true;
})();
require.register("application", function(exports, require, module) {
var Application, GameController, mediator;

GameController = require('controllers/game_controller');

mediator = require('lib/mediator');

Application = {
  initialize: function() {
    this.gameController = new GameController();
    return typeof Object.freeze === "function" ? Object.freeze(this) : void 0;
  }
};

module.exports = Application;
});

;require.register("controllers/game_controller", function(exports, require, module) {
var Avatar, EventBroker, GameController, MapView, Player, mediator, utils;

MapView = require('views/map_view');

mediator = require('lib/mediator');

EventBroker = require('lib/event_broker');

Player = require('models/player');

Avatar = require('views/avatar');

utils = require('lib/utils');

module.exports = GameController = (function() {
  Backbone.utils.extend(GameController.prototype, EventBroker);

  function GameController() {
    this.setupMap();
  }

  GameController.prototype.setupMap = function() {
    this.mapView = new MapView({
      className: 'map',
      el: document.getElementById("map"),
      autoRender: true
    });
    return this.addPlayer();
  };

  GameController.prototype.addPlayer = function() {
    var avatar, player;
    player = new Player({
      id: 1,
      name: "Ross",
      x_position: 400,
      y_position: 400
    });
    avatar = new Avatar({
      model: player
    });
    this.mapView.listenTo(avatar, 'playerMove', this.mapView.checkPlayerPosition);
    return this.mapView.spawnPlayer(player, avatar);
  };

  return GameController;

})();
});

;require.register("initialize", function(exports, require, module) {
var application;

application = require('application');

document.addEventListener("DOMContentLoaded", function() {
  return application.initialize();
});
});

;require.register("lib/event_broker", function(exports, require, module) {
'use strict';
var EventBroker, mediator,
  __slice = [].slice;

mediator = require('lib/mediator');

EventBroker = {
  subscribeEvent: function(type, handler) {
    if (typeof type !== 'string') {
      throw new TypeError('EventBroker#subscribeEvent: ' + 'type argument must be a string');
    }
    if (typeof handler !== 'function') {
      throw new TypeError('EventBroker#subscribeEvent: ' + 'handler argument must be a function');
    }
    mediator.unsubscribe(type, handler, this);
    return mediator.subscribe(type, handler, this);
  },
  subscribeEventOnce: function(type, handler) {
    if (typeof type !== 'string') {
      throw new TypeError('EventBroker#subscribeEventOnce: ' + 'type argument must be a string');
    }
    if (typeof handler !== 'function') {
      throw new TypeError('EventBroker#subscribeEventOnce: ' + 'handler argument must be a function');
    }
    mediator.unsubscribe(type, handler, this);
    return mediator.subscribeOnce(type, handler, this);
  },
  unsubscribeEvent: function(type, handler) {
    if (typeof type !== 'string') {
      throw new TypeError('EventBroker#unsubscribeEvent: ' + 'type argument must be a string');
    }
    if (typeof handler !== 'function') {
      throw new TypeError('EventBroker#unsubscribeEvent: ' + 'handler argument must be a function');
    }
    return mediator.unsubscribe(type, handler);
  },
  unsubscribeAllEvents: function() {
    return mediator.unsubscribe(null, null, this);
  },
  publishEvent: function() {
    var args, type;
    type = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (typeof type !== 'string') {
      throw new TypeError('EventBroker#publishEvent: ' + 'type argument must be a string');
    }
    return mediator.publish.apply(mediator, [type].concat(__slice.call(args)));
  }
};

if (typeof Object.freeze === "function") {
  Object.freeze(EventBroker);
}

module.exports = EventBroker;
});

;require.register("lib/mediator", function(exports, require, module) {
'use strict';
var handlers, mediator,
  __slice = [].slice;

mediator = {};

mediator.subscribe = mediator.on = Backbone.Events.on;

mediator.subscribeOnce = mediator.once = Backbone.Events.once;

mediator.unsubscribe = mediator.off = Backbone.Events.off;

mediator.publish = mediator.trigger = Backbone.Events.trigger;

mediator._callbacks = null;

handlers = mediator._handlers = {};

mediator.setHandler = function(name, method, instance) {
  return handlers[name] = {
    instance: instance,
    method: method
  };
};

mediator.execute = function() {
  var args, handler, name, nameOrObj, silent;
  nameOrObj = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
  silent = false;
  if (typeof nameOrObj === 'object') {
    silent = nameOrObj.silent;
    name = nameOrObj.name;
  } else {
    name = nameOrObj;
  }
  handler = handlers[name];
  if (handler) {
    return handler.method.apply(handler.instance, args);
  } else if (!silent) {
    throw new Error("mediator.execute: " + name + " handler is not defined");
  }
};

mediator.removeHandlers = function(instanceOrNames) {
  var handler, name, _i, _len;
  if (!instanceOrNames) {
    mediator._handlers = {};
  }
  if (Array.isArray(instanceOrNames)) {
    for (_i = 0, _len = instanceOrNames.length; _i < _len; _i++) {
      name = instanceOrNames[_i];
      delete handlers[name];
    }
  } else {
    for (name in handlers) {
      handler = handlers[name];
      if (handler.instance === instanceOrNames) {
        delete handlers[name];
      }
    }
  }
};

mediator.seal = function() {
  if (support.propertyDescriptors && Object.seal) {
    return Object.seal(mediator);
  }
};

module.exports = mediator;
});

;require.register("lib/utils", function(exports, require, module) {
var utils,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

utils = {
  getAllPropertyVersions: function(object, property) {
    var proto, result, value, _i, _len, _ref;
    result = [];
    _ref = utils.getPrototypeChain(object);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      proto = _ref[_i];
      value = proto[property];
      if (value && __indexOf.call(result, value) < 0) {
        result.push(value);
      }
    }
    return result;
  },
  serialize: function(data) {
    if (typeof data.serialize === 'function') {
      return data.serialize();
    } else if (typeof data.toJSON === 'function') {
      return data.toJSON();
    } else {
      throw new TypeError('utils.serialize: Unknown data was passed');
    }
  },
  getPrototypeChain: function(object) {
    var chain, _ref, _ref1, _ref2, _ref3;
    chain = [object.constructor.prototype];
    while (object = (_ref = (_ref1 = object.constructor) != null ? (_ref2 = _ref1.superclass) != null ? _ref2.prototype : void 0 : void 0) != null ? _ref : (_ref3 = object.constructor) != null ? _ref3.__super__ : void 0) {
      chain.push(object);
    }
    return chain.reverse();
  }
};

module.exports = utils;
});

;require.register("models/collection", function(exports, require, module) {
var Collection;

module.exports = Collection = (function() {
  function Collection() {}

  return Collection;

})();
});

;require.register("models/model", function(exports, require, module) {
var EventBroker, Model, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

EventBroker = require('lib/event_broker');

module.exports = Model = (function(_super) {
  __extends(Model, _super);

  function Model() {
    _ref = Model.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Backbone.utils.extend(Model.prototype, EventBroker);

  return Model;

})(Backbone.Model);
});

;require.register("models/player", function(exports, require, module) {
var Model, Player, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Model = require('models/model');

module.exports = Player = (function(_super) {
  __extends(Player, _super);

  function Player() {
    _ref = Player.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Player.prototype.defaults = {
    x_position: 0,
    y_position: 0
  };

  Player.prototype.position = function() {
    return "" + (this.get('x_position')) + "px, " + (this.get('y_position')) + "px";
  };

  return Player;

})(Model);
});

;require.register("views/avatar", function(exports, require, module) {
var Avatar, View, directionsByCode, directionsByName, down, left, right, up, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

View = require('./view');

left = 37;

up = 38;

right = 39;

down = 40;

directionsByName = {
  left: left,
  up: up,
  right: right,
  down: down
};

directionsByCode = {
  37: "left",
  38: "up",
  39: "right",
  40: "down"
};

module.exports = Avatar = (function(_super) {
  __extends(Avatar, _super);

  function Avatar() {
    _ref = Avatar.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Avatar.prototype.template = require('./templates/avatar');

  Avatar.prototype.autoRender = false;

  Avatar.prototype.className = 'avatar';

  Avatar.prototype.movementInc = 10;

  Avatar.prototype.movementLoopInc = 20;

  Avatar.prototype.moving = false;

  Avatar.prototype.activeMovementKeys = [];

  Avatar.prototype.movementKeys = [left, up, right, down];

  Avatar.prototype.initialize = function() {
    Avatar.__super__.initialize.apply(this, arguments);
    return this.listenTo(this.model, "change:x_position change:y_position", this.broadCastMove);
  };

  Avatar.prototype.render = function() {
    Avatar.__super__.render.apply(this, arguments);
    this.positionOnMap();
    this.bindEvents();
    return this.setDimensions();
  };

  Avatar.prototype.bindEvents = function() {
    var _this = this;
    document.addEventListener('keydown', function(e) {
      if (_this.isMovementKey(e)) {
        return _this.handleKeyDown(e);
      }
    });
    return document.addEventListener('keyup', function(e) {
      return _this.stopMovement(e);
    });
  };

  Avatar.prototype.broadCastMove = function(player) {
    return this.trigger('playerMove', player, this);
  };

  Avatar.prototype.handleKeyDown = function(e) {
    var _this = this;
    e.stopPropagation();
    if (this.isMovementKey(e) && this.activeMovementKeys.indexOf(e.keyCode) < 0) {
      this.activeMovementKeys.push(e.keyCode);
      if (!(this.moving || this.movementLoop)) {
        this.clearMovementClasses();
        return this.movementLoop = setInterval(function() {
          return _this.move();
        }, this.movementLoopInc);
      }
    }
  };

  Avatar.prototype.move = function(keys) {
    this.moving = true;
    if (!this.isMovingDirection(up) && !this.isMovingDirection(down) && !this.isMovingDirection(left) && !this.isMovingDirection(right)) {
      this.moving = false;
      this.stopMovementLoop();
    }
    if (this.isMovingDirection(up)) {
      this.model.set('y_position', this.model.get('y_position') + -this.movementInc);
    }
    if (this.isMovingDirection(down)) {
      this.model.set('y_position', this.model.get('y_position') + this.movementInc);
    }
    if (this.isMovingDirection(left)) {
      this.model.set('x_position', this.model.get('x_position') + -this.movementInc);
    }
    if (this.isMovingDirection(right)) {
      this.model.set('x_position', this.model.get('x_position') + this.movementInc);
    }
    this.setMovementClasses();
    return this.positionOnMap();
  };

  Avatar.prototype.positionOnMap = function() {
    this.position_x = this.model.get('x_position');
    this.position_y = this.model.get('y_position');
    return this.el.style.webkitTransform = "translate3d(" + (this.model.position()) + ", 0)";
  };

  Avatar.prototype.stopMovement = function(e) {
    if (e && e.keyCode) {
      if (this.activeMovementKeys.indexOf(e.keyCode) > -1) {
        this.activeMovementKeys.splice(this.activeMovementKeys.indexOf(e.keyCode), 1);
      }
      if (this.activeMovementKeys.length === 0) {
        this.stopMovementLoop();
        this.moving = false;
      }
      if (this.moving) {
        this.el.classList.remove(directionsByCode[e.keyCode]);
      }
    } else {
      this.stopMovementLoop();
      this.activeMovementKeys = [];
      this.moving = false;
    }
    return this.setMovementClasses();
  };

  Avatar.prototype.isMovementKey = function(e) {
    return this.movementKeys.indexOf(e.keyCode) > -1;
  };

  Avatar.prototype.isMovingDirection = function(keyCode) {
    return this.activeMovementKeys.indexOf(keyCode) > -1;
  };

  Avatar.prototype.setMovementClasses = function() {
    var classList;
    classList = this.el.classList;
    if (this.moving) {
      classList.add('moving');
    } else {
      classList.remove('moving');
    }
    if (this.isMovingDirection(up)) {
      classList.add('up');
      classList.remove('down');
    }
    if (this.isMovingDirection(down)) {
      classList.add('down');
      classList.remove('up');
    }
    if (this.isMovingDirection(left)) {
      classList.add('left');
      classList.remove('right');
    }
    if (this.isMovingDirection(right)) {
      classList.add('right');
      return classList.remove('left');
    }
  };

  Avatar.prototype.clearMovementClasses = function() {
    var classList;
    classList = this.el.classList;
    classList.remove('up');
    classList.remove('down');
    classList.remove('left');
    return classList.remove('right');
  };

  Avatar.prototype.stopMovementLoop = function() {
    clearInterval(this.movementLoop);
    return this.movementLoop = null;
  };

  Avatar.prototype.setDimensions = function() {
    var _this = this;
    return setTimeout(function() {
      var avatar_rect;
      avatar_rect = _this.el.getClientRects()[0];
      _this.width = avatar_rect.right - avatar_rect.left;
      return _this.height = avatar_rect.bottom - avatar_rect.top;
    }, 0);
  };

  return Avatar;

})(View);
});

;require.register("views/map_view", function(exports, require, module) {
var MapView, View, template, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

View = require('./view');

template = require('./templates/map');

module.exports = MapView = (function(_super) {
  __extends(MapView, _super);

  function MapView() {
    _ref = MapView.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  MapView.prototype.template = template;

  MapView.prototype.className = "map";

  MapView.prototype.viewport_padding = 100;

  MapView.prototype.offset_x = 0;

  MapView.prototype.offset_y = 0;

  MapView.prototype.render = function() {
    MapView.__super__.render.apply(this, arguments);
    return this.setDimensions();
  };

  MapView.prototype.setDimensions = function() {
    this.rect = document.body.getClientRects()[0];
    return this.viewport = {
      left: this.rect.left + this.viewport_padding,
      top: this.rect.top + this.viewport_padding,
      right: this.rect.right - this.viewport_padding,
      bottom: this.rect.bottom - this.viewport_padding
    };
  };

  MapView.prototype.spawnPlayer = function(player, avatar) {
    avatar.container = this.el;
    return avatar.render();
  };

  MapView.prototype.checkPlayerPosition = function(player, avatar) {
    var pan_down, pan_left, pan_right, pan_up, px, py, within_rect, within_x, within_y;
    px = player.get('x_position');
    py = player.get('y_position');
    within_x = px > this.viewport.left && px < this.viewport.right;
    within_y = py > this.viewport.top && py < this.viewport.bottom;
    within_rect = within_x && within_y;
    pan_right = px > ((this.viewport.right - this.offset_x) - avatar.width);
    pan_left = px < (this.viewport.left - this.offset_x);
    pan_down = py > ((this.viewport.bottom - this.offset_y) - avatar.height);
    pan_up = py < (this.viewport.top - this.offset_y);
    if (pan_left) {
      this.offset_x = this.rect.left + (this.viewport.left - px);
    }
    if (pan_right) {
      this.offset_x = this.rect.left + ((this.viewport.right - avatar.width) - px);
    }
    if (pan_up) {
      this.offset_y = this.rect.top + (this.viewport.top - py);
    }
    if (pan_down) {
      this.offset_y = this.rect.top + ((this.viewport.bottom - avatar.height) - py);
    }
    return this.repositionMap(this.offset_x, this.offset_y);
  };

  MapView.prototype.repositionMap = function(left, top) {
    return this.el.style.webkitTransform = "translate3d(" + left + "px, " + top + "px, 0)";
  };

  return MapView;

})(View);
});

;require.register("views/templates/avatar", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};

buf.push("<h1>Avatar</h1>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/templates/map", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};

buf.push("<div id=\"content\"><h1>Map</h1></div>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/view", function(exports, require, module) {
var $, EventBroker, View, attach, bind, setHTML, utils,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

utils = require('lib/utils');

EventBroker = require('lib/event_broker');

$ = Backbone.$;

bind = (function() {
  if (Function.prototype.bind) {
    return function(item, ctx) {
      return item.bind(ctx);
    };
  } else if (_.bind) {
    return _.bind;
  }
})();

setHTML = (function() {
  if ($) {
    return function(elem, html) {
      return elem.html(html);
    };
  } else {
    return function(elem, html) {
      return elem.innerHTML = html;
    };
  }
})();

attach = (function() {
  if ($) {
    return function(view) {
      var actual;
      actual = $(view.container);
      if (typeof view.containerMethod === 'function') {
        return view.containerMethod(actual, view.el);
      } else {
        return actual[view.containerMethod](view.el);
      }
    };
  } else {
    return function(view) {
      var actual;
      actual = typeof view.container === 'string' ? document.querySelector(view.container) : view.container;
      if (typeof view.containerMethod === 'function') {
        return view.containerMethod(actual, view.el);
      } else {
        return actual[view.containerMethod](view.el);
      }
    };
  }
})();

module.exports = View = (function(_super) {
  __extends(View, _super);

  Backbone.utils.extend(View.prototype, EventBroker);

  View.prototype.autoRender = false;

  View.prototype.autoAttach = true;

  View.prototype.container = null;

  View.prototype.containerMethod = $ ? 'append' : 'appendChild';

  View.prototype.regions = null;

  View.prototype.region = null;

  View.prototype.stale = false;

  View.prototype.noWrap = false;

  View.prototype.keepElement = false;

  View.prototype.subviews = null;

  View.prototype.subviewsByName = null;

  View.prototype.optionNames = ['autoAttach', 'autoRender', 'container', 'containerMethod', 'region', 'regions', 'noWrap'];

  function View(options) {
    var optName, optValue, region, render,
      _this = this;
    if (options) {
      for (optName in options) {
        optValue = options[optName];
        if (__indexOf.call(this.optionNames, optName) >= 0) {
          this[optName] = optValue;
        }
      }
    }
    render = this.render;
    this.render = function() {
      if (_this.disposed) {
        return false;
      }
      render.apply(_this, arguments);
      if (_this.autoAttach) {
        _this.attach.apply(_this, arguments);
      }
      return _this;
    };
    this.subviews = [];
    this.subviewsByName = {};
    if (this.noWrap) {
      if (this.region) {
        region = mediator.execute('region:find', this.region);
        if (region != null) {
          this.el = region.instance.container != null ? region.instance.region != null ? $(region.instance.container).find(region.selector) : region.instance.container : region.instance.$(region.selector);
        }
      }
      if (this.container) {
        this.el = this.container;
      }
    }
    View.__super__.constructor.apply(this, arguments);
    this.delegateListeners();
    if (this.model) {
      this.listenTo(this.model, 'dispose', this.dispose);
    }
    if (this.collection) {
      this.listenTo(this.collection, 'dispose', function(subject) {
        if (!subject || subject === _this.collection) {
          return _this.dispose();
        }
      });
    }
    if (this.regions != null) {
      mediator.execute('region:register', this);
    }
    if (this.autoRender) {
      this.render();
    }
  }

  View.prototype.delegate = function(eventName, second, third) {
    var bound, event, events, handler, list, selector;
    if (Backbone.utils) {
      return Backbone.utils.delegate(this, eventName, second, third);
    }
    if (typeof eventName !== 'string') {
      throw new TypeError('View#delegate: first argument must be a string');
    }
    if (arguments.length === 2) {
      handler = second;
    } else if (arguments.length === 3) {
      selector = second;
      if (typeof selector !== 'string') {
        throw new TypeError('View#delegate: ' + 'second argument must be a string');
      }
      handler = third;
    } else {
      throw new TypeError('View#delegate: ' + 'only two or three arguments are allowed');
    }
    if (typeof handler !== 'function') {
      throw new TypeError('View#delegate: ' + 'handler argument must be function');
    }
    list = (function() {
      var _i, _len, _ref, _results;
      _ref = eventName.split(' ');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        event = _ref[_i];
        _results.push("" + event + ".delegate" + this.cid);
      }
      return _results;
    }).call(this);
    events = list.join(' ');
    bound = bind(handler, this);
    this.$el.on(events, selector || null, bound);
    return bound;
  };

  View.prototype._delegateEvents = function(events) {
    var bound, eventName, handler, key, match, selector, value;
    if (Backbone.View.prototype.delegateEvents.length === 2) {
      return Backbone.View.prototype.delegateEvents.call(this, events, true);
    }
    for (key in events) {
      value = events[key];
      handler = typeof value === 'function' ? value : this[value];
      if (!handler) {
        throw new Error("Method '" + value + "' does not exist");
      }
      match = key.match(/^(\S+)\s*(.*)$/);
      eventName = "" + match[1] + ".delegateEvents" + this.cid;
      selector = match[2];
      bound = bind(handler, this);
      this.$el.on(eventName, selector || null, bound);
    }
  };

  View.prototype.delegateEvents = function(events, keepOld) {
    var classEvents, _i, _len, _ref;
    if (!keepOld) {
      this.undelegateEvents();
    }
    if (events) {
      return this._delegateEvents(events);
    }
    _ref = utils.getAllPropertyVersions(this, 'events');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      classEvents = _ref[_i];
      if (typeof classEvents === 'function') {
        classEvents = classEvents.call(this);
      }
      this._delegateEvents(classEvents);
    }
  };

  View.prototype.undelegate = function(eventName, second, third) {
    var event, events, handler, list, selector;
    if (Backbone.utils) {
      return Backbone.utils.undelegate(this, eventName, second, third);
    }
    if (eventName) {
      if (typeof eventName !== 'string') {
        throw new TypeError('View#undelegate: first argument must be a string');
      }
      if (arguments.length === 2) {
        if (typeof second === 'string') {
          selector = second;
        } else {
          handler = second;
        }
      } else if (arguments.length === 3) {
        selector = second;
        if (typeof selector !== 'string') {
          throw new TypeError('View#undelegate: ' + 'second argument must be a string');
        }
        handler = third;
      }
      list = (function() {
        var _i, _len, _ref, _results;
        _ref = eventName.split(' ');
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          event = _ref[_i];
          _results.push("" + event + ".delegate" + this.cid);
        }
        return _results;
      }).call(this);
      events = list.join(' ');
      return this.$el.off(events, selector || null);
    } else {
      return this.$el.off(".delegate" + this.cid);
    }
  };

  View.prototype.delegateListeners = function() {
    var eventName, key, method, target, version, _i, _len, _ref, _ref1;
    if (!this.listen) {
      return;
    }
    _ref = utils.getAllPropertyVersions(this, 'listen');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      version = _ref[_i];
      if (typeof version === 'function') {
        version = version.call(this);
      }
      for (key in version) {
        method = version[key];
        if (typeof method !== 'function') {
          method = this[method];
        }
        if (typeof method !== 'function') {
          throw new Error('View#delegateListeners: ' + ("listener for \"" + key + "\" must be function"));
        }
        _ref1 = key.split(' '), eventName = _ref1[0], target = _ref1[1];
        this.delegateListener(eventName, target, method);
      }
    }
  };

  View.prototype.delegateListener = function(eventName, target, callback) {
    var prop;
    if (target === 'model' || target === 'collection') {
      prop = this[target];
      if (prop) {
        this.listenTo(prop, eventName, callback);
      }
    } else if (target === 'mediator') {
      this.subscribeEvent(eventName, callback);
    } else if (!target) {
      this.on(eventName, callback, this);
    }
  };

  View.prototype.registerRegion = function(name, selector) {
    return mediator.execute('region:register', this, name, selector);
  };

  View.prototype.unregisterRegion = function(name) {
    return mediator.execute('region:unregister', this, name);
  };

  View.prototype.unregisterAllRegions = function() {
    return mediator.execute({
      name: 'region:unregister',
      silent: true
    }, this);
  };

  View.prototype.subview = function(name, view) {
    var byName, subviews;
    subviews = this.subviews;
    byName = this.subviewsByName;
    if (name && view) {
      this.removeSubview(name);
      subviews.push(view);
      byName[name] = view;
      return view;
    } else if (name) {
      return byName[name];
    }
  };

  View.prototype.removeSubview = function(nameOrView) {
    var byName, index, name, otherName, otherView, subviews, view;
    if (!nameOrView) {
      return;
    }
    subviews = this.subviews;
    byName = this.subviewsByName;
    if (typeof nameOrView === 'string') {
      name = nameOrView;
      view = byName[name];
    } else {
      view = nameOrView;
      for (otherName in byName) {
        otherView = byName[otherName];
        if (!(otherView === view)) {
          continue;
        }
        name = otherName;
        break;
      }
    }
    if (!(name && view && view.dispose)) {
      return;
    }
    view.dispose();
    index = utils.indexOf(subviews, view);
    if (index !== -1) {
      subviews.splice(index, 1);
    }
    return delete byName[name];
  };

  View.prototype.getTemplateData = function() {
    var data, source;
    data = this.model ? utils.serialize(this.model) : this.collection ? {
      items: utils.serialize(this.collection),
      length: this.collection.length
    } : {};
    source = this.model || this.collection;
    if (source) {
      if (typeof source.isSynced === 'function' && !('synced' in data)) {
        data.synced = source.isSynced();
      }
    }
    return data;
  };

  View.prototype.getTemplateFunction = function() {
    throw new Error('View#getTemplateFunction must be overridden');
  };

  View.prototype.render = function() {
    var el, html, templateFunc;
    if (this.disposed) {
      return false;
    }
    templateFunc = this.getTemplateFunction();
    if (typeof templateFunc === 'function') {
      html = templateFunc(this.getTemplateData());
      if (this.noWrap) {
        el = document.createElement('div');
        el.innerHTML = html;
        if (el.children.length > 1) {
          throw new Error('There must be a single top-level element when ' + 'using `noWrap`.');
        }
        this.undelegateEvents();
        this.setElement(el.firstChild, true);
      } else {
        setHTML(($ ? this.$el : this.el), html);
      }
    }
    return this;
  };

  View.prototype.attach = function() {
    if (this.region != null) {
      mediator.execute('region:show', this.region, this);
    }
    if (this.container && !document.body.contains(this.el)) {
      attach(this);
      return this.trigger('addedToDOM');
    }
  };

  View.prototype.disposed = false;

  View.prototype.dispose = function() {
    var prop, properties, subview, _i, _j, _len, _len1, _ref;
    if (this.disposed) {
      return;
    }
    this.unregisterAllRegions();
    _ref = this.subviews;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      subview = _ref[_i];
      subview.dispose();
    }
    this.unsubscribeAllEvents();
    this.off();
    if (this.keepElement) {
      this.undelegateEvents();
      this.undelegate();
      this.stopListening();
    } else {
      this.remove();
    }
    properties = ['el', '$el', 'options', 'model', 'collection', 'subviews', 'subviewsByName', '_callbacks'];
    for (_j = 0, _len1 = properties.length; _j < _len1; _j++) {
      prop = properties[_j];
      delete this[prop];
    }
    this.disposed = true;
    return typeof Object.freeze === "function" ? Object.freeze(this) : void 0;
  };

  View.prototype.getTemplateFunction = function() {
    return this.template;
  };

  return View;

})(Backbone.NativeView);
});

;
//# sourceMappingURL=app.js.map