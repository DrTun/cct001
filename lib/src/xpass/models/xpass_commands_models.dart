enum Commands {
  open,
  close,
  lock,
  unlock,
}

Commands fromJson(String commandString) {
  switch (commandString) {
    case 'open':
      return Commands.open;
    case 'close':
      return Commands.close;
    case 'lock':
      return Commands.lock;
    case 'unlock':
      return Commands.unlock;
    default:
      throw ArgumentError('Unknown command: $commandString');
  }
}
