import java.nio.file.Paths;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

public class Day13 {
      public static void main(String[] args) {
            System.out.println("Hello InfoQ Universe");
            try {
                  var claws = Day13.readInput();
                  long sum = 0;
                  int idx = 1;
                  for (ClawMachine claw : claws) {
                        long res = Day13.requiredTokens(claw);
                        System.out.println("claw " + idx + ": " + res);
                        sum += res;
                        idx += 1;
                  }
                  System.out.println("Part 1: " + sum);

                  var part2Claws = claws.stream().map(claw -> new ClawMachine(claw.ax, claw.ay, claw.bx, claw.by,
                              claw.gx + 10000000000000.0, claw.gy + 10000000000000.0)).toList();
                  sum = 0;
                  idx = 0;
                  for (ClawMachine claw : part2Claws) {
                        long res = Day13.requiredTokens(claw);
                        System.out.println("claw " + idx + ": " + res);
                        sum += res;
                        idx += 1;
                  }
                  System.out.println("Part 2: " + sum);
            } catch (Exception e) {
                  e.printStackTrace();
            }
      }

      record ClawMachine(double ax, double ay, double bx, double by, double gx, double gy) {
      }

      private static ArrayList<ClawMachine> readInput() throws Exception {
            String contents = Files.readString(Paths.get("input.txt"), StandardCharsets.US_ASCII);
            String[] parts = contents.split("\n\n");
            Pattern pattern = Pattern.compile("Button A: X\\+(\\d+), Y\\+(\\d+)\\n" + //
                        "Button B: X\\+(\\d+), Y\\+(\\d+)\\n" + //
                        "Prize: X=(\\d+), Y=(\\d+)");
            ArrayList<ClawMachine> clawMachines = new ArrayList<ClawMachine>();
            for (String part : parts) {
                  Matcher res = pattern.matcher(part);
                  res.find();
                  int ax = Integer.parseInt(res.group(1), 10);
                  int ay = Integer.parseInt(res.group(2), 10);
                  int bx = Integer.parseInt(res.group(3), 10);
                  int by = Integer.parseInt(res.group(4), 10);
                  int gx = Integer.parseInt(res.group(5), 10);
                  int gy = Integer.parseInt(res.group(6), 10);
                  clawMachines.add(new ClawMachine(ax, ay, bx, by, gx, gy));
            }

            return clawMachines;
      }

      private static long requiredTokens(ClawMachine claw) {
            double m1 = claw.ay / claw.ax;
            double b1 = claw.gy - m1 * claw.gx;
            double m2 = claw.by / claw.bx;
            double b2 = 0;

            // Find x coordinate of the intersection pointt
            double x = (b1 - b2) / (m2 - m1);

            long na = (long) Math.round((claw.gx - x) / claw.ax);
            long nb = (long) Math.round(x / claw.bx);
            if (na * claw.ax + nb * claw.bx != claw.gx || na * claw.ay + nb * claw.by != claw.gy) {
                  return 0;
            }
            return 3 * na + nb;
      }
}