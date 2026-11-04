/// The readable text of a message, as it should appear in a desktop
/// notification body.
///
/// Messages can be written by another client that sends HTML, so the raw
/// content is converted to plain text and its entities decoded *before*
/// truncation. Truncating first used to cut a tag or a surrogate pair in half
/// and leave markup in the notification.
String notificationPreview({required Object? content, required bool hasMedia}) {
  final text = _htmlToPlainText(content?.toString() ?? '');

  if (text.isEmpty) {
    return hasMedia ? 'Sent an attachment' : 'New message';
  }

  if (text.length <= 80) return text;
  return '${text.substring(0, 77)}...';
}

String _htmlToPlainText(String raw) {
  if (raw.isEmpty) return '';

  // Drop tags (including the <br> / <p> case, which becomes a space so words
  // on either side do not run together), then decode entities.
  final withoutTags = raw.replaceAll(RegExp(r'<[^>]*>'), ' ');
  final decoded = _decodeEntities(withoutTags);

  // Collapse the whitespace the tag removal leaves behind.
  return decoded.replaceAll(RegExp(r'\s+'), ' ').trim();
}

String _decodeEntities(String input) {
  return input.replaceAllMapped(
    RegExp(r'&(#[0-9]+|#[xX][0-9a-fA-F]+|[a-zA-Z]+);'),
    (match) {
      final entity = match.group(1)!;

      switch (entity) {
        case 'amp':
          return '&';
        case 'lt':
          return '<';
        case 'gt':
          return '>';
        case 'quot':
          return '"';
        case 'apos':
          return "'";
        case 'nbsp':
          return ' ';
        case 'hellip':
          return '\u2026';
        case 'mdash':
          return '\u2014';
        case 'ndash':
          return '\u2013';
      }

      if (entity.startsWith('#x') || entity.startsWith('#X')) {
        final code = int.tryParse(entity.substring(2), radix: 16);
        if (code != null) return String.fromCharCode(code);
      } else if (entity.startsWith('#')) {
        final code = int.tryParse(entity.substring(1));
        if (code != null) return String.fromCharCode(code);
      }

      // An entity we do not know is left exactly as it was.
      return match.group(0)!;
    },
  );
}
