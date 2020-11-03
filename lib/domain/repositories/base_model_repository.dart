import '../content_models.dart';

abstract class ModelRepository {

  List<ContentModel> getModels();

  void setModels(List<ContentModel> models);

  void addModel(ContentModel model);

  void clearModels();

  void removeModel(ContentModel model);

  void removeModelAtPosition(int position);

  ContentModel operator [](int index);

}