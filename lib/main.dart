import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tom\'s Recipes App',
      theme: ThemeData(colorSchemeSeed: Colors.lightGreen, useMaterial3: true),
      home: const RecipeListPage(),
    );
  }
}

// Model for a Recipe
class Recipe {
  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.cookingTime,
    required this.ingredients,
    required this.steps,
  });
  final int id;
  final String title;
  final String imageUrl;
  final String cookingTime;
  final List<String> ingredients;
  final List<String> steps;
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
      MaterialPageRoute<void>(builder: (context) => const SettingsPage()),
    );
  }

  // Navigate to the create recipe page
  Future<void> _navigateToCreateRecipe() async {
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
      appBar: AppBar(title: const Text('Recipes')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Menu')),
            ListTile(
              title: const Text('Settings'),
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
              if (result!) {
                _deleteRecipe(recipe);
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateRecipe,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Page to display the details of a recipe
class RecipeDetailsPage extends StatelessWidget {
  const RecipeDetailsPage({required this.recipe, super.key});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Confirm deletion of the recipe
              showDialog<void>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Delete Recipe'),
                      content: const Text(
                        'Are you sure you want to delete this recipe?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                            Navigator.pop(
                              context,
                              true,
                            ); // Return deletion flag
                          },
                          child: const Text(
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
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 16),
            Text(
              'Cooking Time: ${recipe.cookingTime}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ingredients:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...recipe.ingredients.map((ingredient) => Text('- $ingredient')),
            const SizedBox(height: 16),
            const Text(
              'Steps:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...recipe.steps.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final step = entry.value;
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
  const CreateRecipePage({required this.nextId, super.key});
  final int nextId;

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
      appBar: AppBar(title: const Text('Create Recipe')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
                TextFormField(
                  controller: _cookingTimeController,
                  decoration: const InputDecoration(labelText: 'Cooking Time'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the cooking time';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ingredientsController,
                  decoration: const InputDecoration(
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
                  decoration: const InputDecoration(
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Create Recipe'),
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
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Page - Options go here')),
    );
  }
}
