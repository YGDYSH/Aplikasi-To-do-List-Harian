import 'package:drift/drift.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get note => text().nullable()();

  DateTimeColumn get dueDate => dateTime().nullable()();

  BoolColumn get hasTime => boolean().withDefault(const Constant(false))();

  IntColumn get priority => integer().withDefault(const Constant(0))();

  IntColumn get status => integer().withDefault(const Constant(0))();

  BoolColumn get isDone => boolean().withDefault(const Constant(false))();

  IntColumn get projectId =>
      integer().nullable().references(Projects, #id, onDelete: KeyAction.setNull)();

  DateTimeColumn get reminderAt => dateTime().nullable()();

  TextColumn get repeatRule => text().nullable()();

  DateTimeColumn get completedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();
}

class Labels extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().unique()();

  IntColumn get colorValue => integer()();
}

class TaskLabels extends Table {
  IntColumn get taskId =>
      integer().references(Tasks, #id, onDelete: KeyAction.cascade)();

  IntColumn get labelId =>
      integer().references(Labels, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {taskId, labelId};
}

class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get iconKey => text()();
}
