import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String,dynamic>> tasks = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadTask();
  }

  Future<void> _loadTask()async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('task_list');
    if(data !=null){
      setState(() {
        tasks  = List <Map<String,dynamic>>.from(jsonDecode(data));
        _sortTask();
      });
    }
  }

  Future<void> _saveTask() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('task_list', jsonEncode(tasks));
  }

  void _addTask(String taskTitle) {
    if (taskTitle.trim().isEmpty) return;
    setState(() {
      tasks.add({'title': taskTitle, 'isComplete': false});
      _sortTask();
    });
    _saveTask();
    _taskController.clear();
    Navigator.pop(context);
  }

  void _deleteTask(int index){
    setState(() {
      tasks.removeAt(index);
    });
    _saveTask();
  }

  void _toggleComplete(int index){
    setState(() {
      tasks[index]['isComplete'] = !tasks[index]['isComplete'];
    });
    _sortTask();
    _saveTask();
  }

  void _sortTask (){
    tasks.sort((a, b){
      if(a['isComplete'] == b['isComplete']) return 0;
      return a['isComplete'] ? 1 : -1;
    });
  }

  void _showAddTaskSheet (){
    showModalBottomSheet(
      backgroundColor: Colors.grey.shade200,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
        ),
        context:  context,
        builder: (_)=> Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: 'Enter a new task',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16)
                )
              ),
            ),
            const SizedBox(height: 10,),
            ElevatedButton.icon(onPressed: ()=> _addTask(_taskController.text), icon: const Icon(Icons.add),label: const Text('Add Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),)
          ],
        ),));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        title:const Text(
          'Your Tasks!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _showAddTaskSheet, icon: const Icon(Icons.add_task_rounded))
        ],
      ),
      body: tasks.isEmpty ? const Center(child: Text('No Tasks yet!',style: TextStyle(fontSize: 18),),)
      : ListView.separated(
        itemCount: tasks.length,
        separatorBuilder: (_, _) => const SizedBox(height: 4,),
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade300,
              ),
              child: ListTile(
                leading: GestureDetector(
                  onTap:()=> _toggleComplete(index),
                  child: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      color: task['isComplete']
                          ? Colors.grey.shade500
                          : Colors.transparent,
                      border: Border.all(
                        color: task['isComplete']
                            ? Colors.transparent
                            : Colors.grey.shade500,
                        width: 3,
                      ),
                    ),
                    child: task['isComplete'] ? Icon(Icons.done, size: 21) : null,
                  ),
                ),
                title: Text(
                  task['title'],
                  style: TextStyle(
                    decoration: task['isComplete'] ? TextDecoration.lineThrough : null,fontSize: 16,
                  ),
                ),
                trailing: IconButton(onPressed: ()=>_deleteTask(index),icon:const Icon(Icons.delete_forever), color: Colors.redAccent),
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(onPressed: _showAddTaskSheet,backgroundColor: Colors.black87,
      child: const Icon(Icons.add,color: Colors.white,),),
    );
  }
}
