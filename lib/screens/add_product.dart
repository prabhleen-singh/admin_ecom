import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../db/category.dart';
import '../db/brand.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as Path;

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  CategoryService _categoryService = CategoryService();
  BrandService _brandService = BrandService();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController productNameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown = <
      DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];
  String _currentCategory;
  String _currentBrand;
  Color white = Colors.white;
  Color black = Colors.black;
  Color grey = Colors.grey;
  Color red = Colors.red;
  List<String> selectedSizes = <String>[];
  File _image1;
  File _image2;
  File _image3;
  String _uploadedFileURL;


  @override
  void initState() {
    _getCategories();
    _getBrands();
  }

  List<DropdownMenuItem<String>> getCategoriesDropdown() {
    List<DropdownMenuItem<String>> items = new List();
    for (int i = 0; i < categories.length; i++) {
      setState(() {
        items.insert(
            0, DropdownMenuItem(child: Text(categories[i].data['category']),
            value: categories[i].data['category']));
      });
    }
    return items;
  }

  List<DropdownMenuItem<String>> getBrandsDropDown() {
    List<DropdownMenuItem<String>> items = new List();
    for (int i = 0; i < brands.length; i++) {
      setState(() {
        items.insert(0, DropdownMenuItem(child: Text(brands[i].data['brand']),
            value: brands[i].data['brand']));
      });
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: white,
        //leading: Icon(Icons.close, color: black),
        actions: <Widget>[
          IconButton(
            icon: Icon( Icons.close, color: black ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
        title: Text("add product", style: TextStyle(color: black),),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                          borderSide: BorderSide(color: grey.withOpacity(0.5),
                              width: 2.5),
                          onPressed: () {
                            _selectImage(ImagePicker.pickImage(
                                source: ImageSource.gallery), 1);
                          },
                          child: _displayChild1()
                      ),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                          borderSide: BorderSide(color: grey.withOpacity(0.5),
                              width: 2.5),
                          onPressed: () {
                            _selectImage(ImagePicker.pickImage(
                                source: ImageSource.gallery), 2);
                          },
                          child: _displayChild2()
                      ),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                        borderSide: BorderSide(color: grey.withOpacity(0.5),
                            width: 2.5),
                        onPressed: () {
                          _selectImage(ImagePicker.pickImage(
                              source: ImageSource.gallery), 3);
                        },
                        child: _displayChild3(),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Please Enter Product Name',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: red, fontSize: 12),),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  controller: productNameController,
                  decoration: InputDecoration(
                      hintText: 'Product name'
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'You must enter the product name';
                    }
//                    else if(value.length > 10){
//                      return 'Product name cant have more than 10 letters';
//                    }
                  },
                ),
              ),

//              select category
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Category: ', style: TextStyle(color: red),),
                  ),
                  DropdownButton(items: categoriesDropDown,
                    onChanged: changeSelectedCategory,
                    value: _currentCategory,),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Brand: ', style: TextStyle(color: red),),
                  ),
                  DropdownButton(items: brandsDropDown,
                    onChanged: changeSelectedBrand,
                    value: _currentBrand,),
                ],
              ),

//
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Quantity',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'You must enter the product quantity';
                    }
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Price per unit',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'You must enter the product price';
                    }
                  },
                ),
              ),
//          Commented out the following code as we don't ned size option in this app
//              Text('Available Sizes'),
//
//              Row(
//                children: <Widget>[
//                  Checkbox(value: selectedSizes.contains('XS'), onChanged: (value) => changeSelectedSize('XS')),
//                  Text('XS'),
//
//                  Checkbox(value: selectedSizes.contains('S'), onChanged: (value) => changeSelectedSize('S')),
//                  Text('S'),
//
//                  Checkbox(value: selectedSizes.contains('M'), onChanged: (value) => changeSelectedSize('M')),
//                  Text('M'),
//
//                  Checkbox(value: selectedSizes.contains('L'), onChanged: (value) => changeSelectedSize('L')),
//                  Text('L'),
//
//                  Checkbox(value: selectedSizes.contains('XL'), onChanged: (value) => changeSelectedSize('XL')),
//                  Text('XL'),
//
//                  Checkbox(value: selectedSizes.contains('XXL'), onChanged: (value) => changeSelectedSize('XXL')),
//                  Text('XXL'),
//                ],
//              ),
//
//              Row(
//                children: <Widget>[
//                  Checkbox(value: selectedSizes.contains('28'), onChanged: (value) => changeSelectedSize('28')),
//                  Text('28'),
//
//                  Checkbox(value: selectedSizes.contains('30'), onChanged: (value) => changeSelectedSize('30')),
//                  Text('30'),
//
//                  Checkbox(value: selectedSizes.contains('32'), onChanged: (value) => changeSelectedSize('32')),
//                  Text('32'),
//
//                  Checkbox(value: selectedSizes.contains('34'), onChanged: (value) => changeSelectedSize('34')),
//                  Text('34'),
//
//
//                  Checkbox(value: selectedSizes.contains('36'), onChanged: (value) => changeSelectedSize('36')),
//                  Text('36'),
//
//                  Checkbox(value: selectedSizes.contains('38'), onChanged: (value) => changeSelectedSize('38')),
//                  Text('38'),
//                ],
//              ),
//
//              Row(
//                children: <Widget>[
//                  Checkbox(value: selectedSizes.contains('40'), onChanged: (value) => changeSelectedSize('40')),
//                  Text('40'),
//
//                  Checkbox(value: selectedSizes.contains('42'), onChanged: (value) => changeSelectedSize('42')),
//                  Text('42'),
//
//                  Checkbox(value: selectedSizes.contains('44'), onChanged: (value) => changeSelectedSize('44')),
//                  Text('44'),
//
//                  Checkbox(value: selectedSizes.contains('46'), onChanged: (value) => changeSelectedSize('46')),
//                  Text('46'),
//
//                  Checkbox(value: selectedSizes.contains('48'), onChanged: (value) => changeSelectedSize('48')),
//                  Text('48'),
//
//                  Checkbox(value: selectedSizes.contains('50'), onChanged: (value) => changeSelectedSize('50')),
//                  Text('50'),
//                ],
//              ),

              FlatButton(
                color: red,
                textColor: white,
                child: Text('add product'),
                onPressed: () {
                  validateAndUpload();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  _getCategories() async {
    List<DocumentSnapshot> data = await _categoryService.getCategories();
    print(data.length);
    setState(() {
      categories = data;
      categoriesDropDown = getCategoriesDropdown();
      _currentCategory = categories[0].data['category'];
    });
  }

  _getBrands() async {
    List<DocumentSnapshot> data = await _brandService.getBrands();
    print(data.length);
    setState(() {
      brands = data;
      brandsDropDown = getBrandsDropDown();
      _currentBrand = brands[0].data['brand'];
    });
  }

  changeSelectedCategory(String selectedCategory) {
    setState(() => _currentCategory = selectedCategory);
  }

  changeSelectedBrand(String selectedBrand) {
    setState(() => _currentCategory = selectedBrand);
  }

//  void changeSelectedSize(String size) {
//    if(selectedSizes.contains(size)){
//      setState(() {
//        selectedSizes.remove(size);
//      });
//    }else{
//      setState(() {
//        selectedSizes.insert(0, size);
//      });
//    }
//  }

  void _selectImage(Future<File> pickImage, int imageNumber) async {
    File tempImg = await pickImage;
    switch (imageNumber) {
      case 1:
        setState(() => _image1 = tempImg);
        break;
      case 2:
        setState(() => _image2 = tempImg);
        break;
      case 3:
        setState(() => _image3 = tempImg);
        break;
    }
  }

  Widget _displayChild1() {
    if (_image1 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 70, 14, 70),
        child: new Icon(Icons.add, color: grey,),
      );
    } else {
      return Image.file(_image1, fit: BoxFit.fill, width: double.infinity,);
    }
  }

  Widget _displayChild2() {
    if (_image2 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 70, 14, 70),
        child: new Icon(Icons.add, color: grey,),
      );
    } else {
      return Image.file(_image2, fit: BoxFit.fill, width: double.infinity,);
    }
  }

  Widget _displayChild3() {
    if (_image3 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 70, 14, 70),
        child: new Icon(Icons.add, color: grey,),
      );
    } else {
      return Image.file(_image3, fit: BoxFit.fill, width: double.infinity,);
    }
  }

  void validateAndUpload() {
    var id = Uuid();
    String productId = id.v1();
    Firestore storage = Firestore.instance;
    if (_formKey.currentState.validate()) {
      if (_image1 != null && _image2 != null && _image3 != null) {
//        if(selectedSizes.isNotEmpty){
        String imageUrl;
        final String picture = "${DateTime
            .now()
            .millisecondsSinceEpoch
            .toString()}.jpg";
//        }\\\
//      else{
//          Fluttertoast.showToast(msg: 'select at least one size');
      } else {
        Fluttertoast.showToast(msg: 'all the images must be provided');
      }
      storage.collection('products').document(productId).setData(
          {'product': productNameController.text,'quantity': quantityController.text,'price': priceController.text});
      uploadFile(_image1);
      storage.collection('products').document(productId).setData(
          {'picture1': _uploadedFileURL},merge: true);
      uploadFile(_image2);
      storage.collection('products').document(productId).setData(
          {'picture2': _uploadedFileURL},merge: true);
      uploadFile(_image3);
      storage.collection('products').document(productId).setData(
          {'picture3': _uploadedFileURL},merge: true);

//      storage.collection('products').document(productId).setData(
//          {'Picture': _uploadedFileURL});
      Fluttertoast.showToast(msg: 'Product details have been stored');
    }
  }
// ---------Uploading Image in Firebase and Fetch URL to store it in Firestore--------------------
  Future uploadFile(File image) async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child(productNameController.text+'/${Path.basename(image.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.onComplete;
//    print('File image Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
      });
    });
  }
}