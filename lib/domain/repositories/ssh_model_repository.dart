import 'package:flutter_app/domain/content_models.dart';
import 'package:flutter_app/domain/repositories/ssh_key.dart';

import 'base_model_repository.dart';

class SSHModelRepository extends ModelRepository {
  SSHModelRepository(): super() {
    _models.add(SSHConnectionModel(
      sshHost: 'database.aether-project.games',
      sshPort: 22,
      sshUsername: 'root',
      sshPrivateKey: SSHKey.KEY,
    ),
    );
    _models.add(SSHConnectionModel(
      sshHost: 'mc.aether-project.games',
      sshPort: 22,
      sshUsername: 'root',
      sshPrivateKey: SSHKey.KEY,
    ),
    );
  }

  List<SSHConnectionModel> _models = List();

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
