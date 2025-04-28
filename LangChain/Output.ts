class Tested {
    
    public static getCorrectIndentLevel(lines: string[], lineIndex: number): string {
        if (lineIndex < 0 || lineIndex >= lines.length) {
            return "";
        }
        const currentLine = lines[lineIndex];
        if (lineIndex === 0) {
            return "";
        }
        const previousLine = lines[lineIndex - 1];
        if (!previousLine.isEmpty() && !previousLine.trim().endsWith(",")) {
            return this.getIndentation(previousLine);
        }
        if (previousLine.trim().startsWith("class ") || previousLine.trim().startsWith("def ") || previousLine.endsWith(":")) {
            return this.getIndentation(previousLine) + "  ";
        }
        for (const line of lines) {
            if (line.length >= 8 && line.substring(0, 8).trim().isEmpty()) {
                return this.getIndentation(line);
            }
        }
        return "";
    }

    private static getIndentation(line: string): string {
        let index = 0;
        while (index < line.length && /\s/.test(line.charAt(index))) {
            index++;
        }
        return line.substring(0, index);
    }
}