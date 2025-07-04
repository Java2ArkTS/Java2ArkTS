package p0;
import java.util.List;

public class Tested {
    public static String _get_correct_indent_level(List<String> lines, int lineIndex) {
        if (lineIndex < 0 || lineIndex >= lines.size()) {
            return "";
        }

        String currentLine = lines.get(lineIndex);
        if (lineIndex == 0) {
            return "";
        }

        String previousLine = lines.get(lineIndex - 1);
        if (!previousLine.isEmpty() && !previousLine.trim().endsWith(",")) {
            return getIndentation(previousLine);
        }

        if (previousLine.trim().startsWith("class ") || previousLine.trim().startsWith("def ") || previousLine.endsWith(":")) {
            return getIndentation(previousLine) + "  ";
        }

        for (String line : lines) {
            if (line.length() >= 8 && line.substring(0, 8).trim().isEmpty()) {
                return getIndentation(line);
            }
        }

        return "";
    }

    private static String getIndentation(String line) {
        int index = 0;
        while (index < line.length() && Character.isWhitespace(line.charAt(index))) {
            index++;
        }
        return line.substring(0, index);
    }
}