import 'dart:io';
import 'package:flutter/material.dart';
import 'package:detto/models/catalogo_model.dart';
import 'package:detto/database/catalogo_dao.dart';
import 'package:detto/database/database_helper.dart';
import 'package:video_player/video_player.dart';

class Paginacatalogo extends StatefulWidget {
  @override
  _PaginaCatalogoState createState() => _PaginaCatalogoState();
}

class _PaginaCatalogoState extends State<Paginacatalogo> {
  late CatalogoDao _catalogoDao;
  late Future<List<CatalogoItem>> _productsFuture;
  List<CatalogoItem> _products = [];
  List<String> _filterOptions = [
    'Nombre',
    'Tallas',
    'Material',
    'Colores',
    'Género',
    'Campo',
  ];
  Map<String, List<String>> _selectedFilterValues = {
    'Nombre': [],
    'Tallas': [],
    'Material': [],
    'Colores': [],
    'Género': [],
    'Campo': [],
  };
  List<String> _selectedFilterOptions = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    _catalogoDao = CatalogoDao(await DatabaseHelper.instance.db);
    await _catalogoDao.initDatabase();
    _productsFuture = _catalogoDao.readAll();
    _productsFuture.then((products) {
      setState(() {
        _products = products;
      });
    });
  }

  void _filterProducts() {
    List<CatalogoItem> filteredProducts = _products;

    filteredProducts = filteredProducts.where((product) {
      for (String option in _selectedFilterOptions) {
        switch (option) {
          case 'Nombre':
            if (product.nombrePrenda == null || !_selectedFilterValues[option]!.contains(product.nombrePrenda)) {
              return false;
            }
            break;
          case 'Tallas':
            if (product.tallas == null || !_selectedFilterValues[option]!.contains(product.tallas)) {
              return false;
            }
            break;
          case 'Material':
            if (product.material == null || !_selectedFilterValues[option]!.contains(product.material)) {
              return false;
            }
            break;
          case 'Colores':
            if (product.colores == null || !_selectedFilterValues[option]!.contains(product.colores)) {
              return false;
            }
            break;
          case 'Género':
            if (product.genero == null || !_selectedFilterValues[option]!.contains(product.genero)) {
              return false;
            }
            break;
          case 'Campo':
            if (product.campo == null || !_selectedFilterValues[option]!.contains(product.campo)) {
              return false;
            }
            break;
          default:
            break;
        }
      }
      return true;
    }).toList();

    setState(() {
      _products = filteredProducts;
    });
  }

  Future<void> _showFilterDialog(String option) async {
    List<String>? values;
    switch (option) {
      case 'Nombre':
        values = _products.map((product) => product.nombrePrenda ?? '').toSet().toList();
        break;
      case 'Tallas':
        values = _products.map((product) => product.tallas ?? '').toSet().toList();
        break;
      case 'Material':
        values = _products.map((product) => product.material ?? '').toSet().toList();
        break;
      case 'Colores':
        values = _products.map((product) => product.colores ?? '').toSet().toList();
        break;
      case 'Género':
        values = _products.map((product) => product.genero ?? '').toSet().toList();
        break;
      case 'Campo':
        values = _products.map((product) => product.campo ?? '').toSet().toList();
        break;
      default:
        break;
    }

    List<String>? selectedValues = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Selecciona ${option.toLowerCase()}'),
              content: SingleChildScrollView(
                child: Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: values!.map((value) {
                      return CheckboxListTile(
                        title: Text(value),
                        value: _selectedFilterValues[option]?.contains(value) ?? false,
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked!) {
                              _selectedFilterValues[option]!.add(value);
                            } else {
                              _selectedFilterValues[option]!.remove(value);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Aplicar'),
                  onPressed: () {
                    _selectedFilterOptions.add(option);
                    _filterProducts();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );

    setState(() {
      _selectedFilterValues[option] = selectedValues ?? [];
    });
  }

  void _removeFilter(String option) {
    setState(() {
      _selectedFilterOptions.remove(option);
      _selectedFilterValues[option]!.clear();
      if (_selectedFilterOptions.isEmpty) {
        _resetFilters(); // Restaurar el catálogo original si no hay filtros seleccionados
      } else {
        _filterProducts(); // Aplicar los filtros restantes
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedFilterOptions.clear();
      _selectedFilterValues.forEach((key, value) {
        value.clear();
      });
      _productsFuture.then((products) {
        setState(() {
          _products = products;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo'),
        actions: [
          DropdownButton<String>(
            value: null,
            items: _filterOptions.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                _showFilterDialog(newValue);
              }
            },
          ),
          _selectedFilterOptions.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.filter_alt),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Filtros seleccionados'),
                          content: SingleChildScrollView(
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: _selectedFilterOptions.map((option) {
                                return Chip(
                                  label: Text(option),
                                  onDeleted: () {
                                    _removeFilter(option);
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cerrar'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                )
              : SizedBox(),
        ],
      ),
      body: _products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two items per row
                childAspectRatio: 0.75, // Aspect ratio of boxes
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(product: product),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final CatalogoItem product;
  final Function onTap;

  const ProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        onTap: () => onTap(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
              child: Image.file(
                File(product.fotos ?? ''),
                fit: BoxFit.cover,
                height: 150,
              ),
            ),
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nombrePrenda ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    product.descripcion != null && product.descripcion!.length > 50
                        ? product.descripcion!.substring(0, 50) + '...'
                        : product.descripcion ?? '',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final CatalogoItem product;

  const ProductDetailPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.nombrePrenda ?? ''),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Image.file(
                    File(product.fotos ?? ''),
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem('Nombre:', product.nombrePrenda ?? ''),
                  _buildDetailItem('Tallas:', product.tallas ?? ''),
                  _buildDetailItem('Material:', product.material ?? ''),
                  _buildDetailItem('Colores:', product.colores ?? ''),
                  _buildDetailItem('Género:', product.genero ?? ''),
                  _buildDetailItem('Campo:', product.campo ?? ''),
                  _buildDetailItem('Descripción:', product.descripcion ?? ''),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Show video if exists
            if (product.video != null && product.video!.isNotEmpty)
              VideoPlayerWidget(videoPath: product.video!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  const VideoPlayerWidget({required this.videoPath});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.file(File(widget.videoPath));
    _initializeVideoPlayerFuture = _videoController.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _videoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoPlayer(_videoController),
                _ControlsOverlay(controller: _videoController),
              ],
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _ControlsOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Container()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.replay_10),
                  onPressed: () {
                    controller.seekTo(controller.value.position - Duration(seconds: 10));
                  },
                ),
                IconButton(
                  icon: Icon(controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    if (controller.value.isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.forward_10),
                  onPressed: () {
                    controller.seekTo(controller.value.position + Duration(seconds: 10));
                  },
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.fullscreen),
              onPressed: () {
                if (controller.value.isPlaying) {
                  controller.pause();
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenVideoPlayer(controller: controller),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatelessWidget {
  final VideoPlayerController controller;

  const FullScreenVideoPlayer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}
