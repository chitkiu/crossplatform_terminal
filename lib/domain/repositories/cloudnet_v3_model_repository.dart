import '../content_models.dart';

import 'base_model_repository.dart';

class CloudNetV3ModelRepository extends ModelRepository {

  List<CloudNetV3ServerModel> _models = List();

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
  void clearModels() {
    _models.clear();
  }

  @override
  ContentModel operator [](int index) => _models[index];
}
