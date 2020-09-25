import 'package:flutter_app/domain/content_models.dart';

import 'base_model_repository.dart';

class FTPModelRepository extends ModelRepository {

  List<FTPConnectionModel> _models = List();

  @override
  List<ContentModel> getModels() => _models;

  @override
  void setModels(List<ContentModel> models) {
    _models = models;
  }

  @override
  void addModel(ContentModel model) {
    _models.add(model);
  }

  @override
  void removeModel(ContentModel model) {
    _models.remove(model);
  }

  @override
  void removeModelAtPosition(int position) {
    _models.removeAt(position);
  }

  @override
  ContentModel operator [](int index) => _models[index];
}