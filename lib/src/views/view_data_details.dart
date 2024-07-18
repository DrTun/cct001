
import 'package:flutter/material.dart';
import '../sqflite/sqf_helpers.dart';
import '../sqflite/sqf_models.dart';


class ViewDataDetails extends StatefulWidget {
  const ViewDataDetails({super.key});
  static const routeName = "/NoteDetailData";

  @override
  State<ViewDataDetails> createState() => _FormDetailDataState();
}

class _FormDetailDataState extends State<ViewDataDetails> {
  final _formKey = GlobalKey<FormState>();
  int? _priority = 0;
  late NoteModel noteModel =  NoteModel();
  final TextEditingController titleController =  TextEditingController();
  final TextEditingController descController = TextEditingController();
    

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(ModalRoute.of(context)!.settings.arguments!=null){
        noteModel = ModalRoute.of(context)!.settings.arguments as NoteModel;
      }
      titleController.text =  noteModel.title!;
      descController.text = noteModel.description!;
      setState(() {
        _priority = noteModel.priority;
      });
    });
    
    
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose(); // Dispose of the current state of FormState
    super.dispose();
  }


  Widget dropDownWidget(){
    return Container(
      margin: const EdgeInsets.all(8),
      width: 100,
      child: DropdownButtonFormField<int>(
        value: _priority,
        decoration: const InputDecoration(
          labelText: 'Priority',
          border: OutlineInputBorder(
            borderRadius:  BorderRadius.all(Radius.circular(10))
          ),
        ),
        items: const [
          DropdownMenuItem<int>(
            value: 0,
            child: Text('High'),
          ),
          DropdownMenuItem<int>(
            value: 1,
            child: Text('Low'),
          ),
        ],
        onChanged: (int? value) {
          setState(() {
            _priority = value!;
          });
        },
      ),
    );
  }

  Widget textForm({
    required TextEditingController controller,
    required String hintText
  }){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: hintText,
          border: const OutlineInputBorder(
            borderRadius:  BorderRadius.all(Radius.circular(8))
          ),
        ),
        validator: (value) {
          if(value=="" || value == null){
            return "Please Enter $hintText";
          }
          return null;
        },
      ),
    );
  }

  Widget saveButton({
    required BuildContext context,
    required TextEditingController descController,
    required TextEditingController titleController,
    required String? noteSyskey,
  }){
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: (){
          if(!_formKey.currentState!.validate()){
            return ;
          }
      
          if(noteSyskey == ""){
            //insert
            DateTime now = DateTime.now();
            final String generateSyskey = '${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}';
            DatabaseHelper().insertNote(
              NoteModel(
                syskey: generateSyskey,
                description: descController.text,
                title: titleController.text,
                priority: _priority
              )
            );
          }else{
            //update
            DatabaseHelper().updateNoteItem(
              NoteModel(
                syskey: noteSyskey,
                title: titleController.text,
                description: descController.text,
                priority: _priority
              )
            );
          }
          
          Navigator.pop(context,true);
        }, 
        child: Text(noteSyskey==""?"Save":"Update")
      ),
    );
  }

  Widget deleteButton({
    required BuildContext context,
    required String? noteSyskey,
  }){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: (){
          DatabaseHelper().deleteNoteItem(syskey: noteSyskey);
          Navigator.pop(context,true);
        }, 
        child: const Text("Delete")
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    
    return Scaffold(
      appBar: AppBar(
        title: Text(noteModel.syskey==""?"Add Note":"Edit Note"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            dropDownWidget(),
            textForm(controller: titleController, hintText: "Title"),      
            textForm(controller: descController, hintText: "Description"),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                saveButton(context:context , titleController: titleController, descController: descController, noteSyskey: noteModel.syskey),
                (noteModel.syskey=="")
                  ? const SizedBox()
                  : deleteButton(context:context , noteSyskey: noteModel.syskey)
              ]
            )
            
          ],
        ),
      ),
    );
  }
}