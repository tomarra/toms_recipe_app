import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipes App',
      theme: ThemeData(colorSchemeSeed: Colors.lightGreen, useMaterial3: true),
      home: RecipeListPage(),
    );
  }
}

// Model for a Recipe
class Recipe {
  final int id;
  final String title;
  final String imageUrl;
  final String cookingTime;
  final List<String> ingredients;
  final List<String> steps;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.cookingTime,
    required this.ingredients,
    required this.steps,
  });
}

// Main Page that displays a list of recipes
class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  RecipeListPageState createState() => RecipeListPageState();
}

class RecipeListPageState extends State<RecipeListPage> {
  List<Recipe> recipes = [];
  int _nextId = 1;

  @override
  void initState() {
    super.initState();
    // Sample recipes built into the app
    recipes = [
      Recipe(
        id: _nextId++,
        title: 'Spaghetti Bolognese',
        imageUrl:
            'https://www.recipetineats.com/tachyon/2018/07/Spaghetti-Bolognese.jpg?resize=900%2C1260&zoom=0.72',
        cookingTime: '30 mins',
        ingredients: [
          'Spaghetti',
          'Minced Meat',
          'Tomato Sauce',
          'Onion',
          'Garlic',
        ],
        steps: [
          'Boil spaghetti',
          'Cook meat',
          'Add tomato sauce',
          'Mix together',
        ],
      ),
      Recipe(
        id: _nextId++,
        title: 'Chicken Curry',
        imageUrl:
            'https://www.allrecipes.com/thmb/5cHs2EbIqqjkg8oz-vXzuUpMD2w=/0x512/filters:no_upscale():max_bytes(150000):strip_icc()/46822-indian-chicken-curry-ii-DDMFS-4x3-39160aaa95674ee395b9d4609e3b0988.jpg',
        cookingTime: '45 mins',
        ingredients: [
          'Chicken',
          'Curry Powder',
          'Coconut Milk',
          'Onion',
          'Garlic',
        ],
        steps: [
          'Cut chicken into pieces',
          'Cook onion and garlic',
          'Add chicken and curry powder',
          'Stir in coconut milk and simmer',
        ],
      ),
    ];
  }

  // Add a new recipe
  /*void _addRecipe(Recipe recipe) {
    setState(() {
      recipes.add(recipe);
    });
  }*/

  // Delete a recipe from the list
  void _deleteRecipe(Recipe recipe) {
    setState(() {
      recipes.removeWhere((r) => r.id == recipe.id);
    });
  }

  // Navigate to the settings page
  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }

  // Navigate to the create recipe page
  void _navigateToCreateRecipe() async {
    final newRecipe = await Navigator.push<Recipe>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRecipePage(nextId: _nextId),
      ),
    );
    if (newRecipe != null) {
      setState(() {
        recipes.add(newRecipe);
        _nextId++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recipes')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text('Menu')),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _navigateToSettings();
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return ListTile(
            leading: Image.network(
              recipe.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(recipe.title),
            subtitle: Text('Cooking Time: ${recipe.cookingTime}'),
            onTap: () async {
              // Navigate to the details page and wait for deletion confirmation
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailsPage(recipe: recipe),
                ),
              );
              if (result == true) {
                _deleteRecipe(recipe);
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateRecipe,
        child: Icon(Icons.add),
      ),
    );
  }
}

// Page to display the details of a recipe
class RecipeDetailsPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailsPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Confirm deletion of the recipe
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('Delete Recipe'),
                      content: Text(
                        'Are you sure you want to delete this recipe?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                            Navigator.pop(
                              context,
                              true,
                            ); // Return deletion flag
                          },
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                recipe.imageUrl,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Cooking Time: ${recipe.cookingTime}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Ingredients:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...recipe.ingredients.map((ingredient) => Text('- $ingredient')),
            SizedBox(height: 16),
            Text(
              'Steps:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...recipe.steps.asMap().entries.map((entry) {
              int idx = entry.key + 1;
              String step = entry.value;
              return Text('$idx. $step');
            }),
          ],
        ),
      ),
    );
  }
}

// Page to create a new recipe
class CreateRecipePage extends StatefulWidget {
  final int nextId;
  const CreateRecipePage({super.key, required this.nextId});

  @override
  CreateRecipePageState createState() => CreateRecipePageState();
}

class CreateRecipePageState extends State<CreateRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
    _cookingTimeController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final recipe = Recipe(
        id: widget.nextId,
        title: _titleController.text,
        imageUrl:
            _imageUrlController.text.isNotEmpty
                ? _imageUrlController.text
                : 'https://picsum.photos/420/320?image=0',
        cookingTime: _cookingTimeController.text,
        ingredients: _ingredientsController.text.split('\n'),
        steps: _stepsController.text.split('\n'),
      );
      Navigator.pop(context, recipe);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Recipe')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(labelText: 'Image URL'),
                ),
                TextFormField(
                  controller: _cookingTimeController,
                  decoration: InputDecoration(labelText: 'Cooking Time'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the cooking time';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ingredientsController,
                  decoration: InputDecoration(
                    labelText: 'Ingredients (one per line)',
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter at least one ingredient';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _stepsController,
                  decoration: InputDecoration(
                    labelText: 'Steps (one per line)',
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the steps';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text('Create Recipe'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Simple settings page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(child: Text('Settings Page - Options go here')),
    );
  }
}
