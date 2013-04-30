### Mongoose-Builder  WIP

Initializes models from a relationship file and enriches those models
with registered plugins.

```javascript

var MongooseBuilder = require("mongoose-builder");
var mongooseBuilder = new MongooseBuilder(relationalFile, schemaFile, dbSettings);

mongooseBuilder.registerPlugin("SomePlugin", Plugin);

...

//supply builder to a model director
director = new Director(graph, mongooseBuilder);
director.build(...);
```
**More to come**
