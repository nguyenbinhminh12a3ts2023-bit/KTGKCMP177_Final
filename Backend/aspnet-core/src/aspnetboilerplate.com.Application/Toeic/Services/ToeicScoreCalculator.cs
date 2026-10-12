namespace aspnetboilerplate.com.Toeic.Services;

public static class ToeicScoreCalculator
{
    private static readonly int[] ReadingScale = new int[101]
    {
        5,  5,  5,  5,  5,  5,  5,  5,  5,  5,    // 0-9
        10, 15, 20, 25, 30, 35, 40, 45, 50, 55,   // 10-19
        60, 65, 70, 75, 80, 85, 90, 95, 100, 105, // 20-29
        110, 115, 120, 125, 130, 135, 140, 145, 150, 155, // 30-39
        160, 165, 170, 175, 180, 185, 190, 195, 200, 205, // 40-49
        210, 215, 220, 225, 230, 235, 240, 245, 250, 255, // 50-59
        260, 265, 270, 275, 280, 285, 290, 295, 300, 305, // 60-69
        310, 315, 320, 325, 330, 335, 340, 345, 350, 355, // 70-79
        360, 365, 370, 375, 380, 385, 390, 395, 400, 410, // 80-89
        420, 430, 440, 450, 460, 470, 480, 490, 495, 495, // 90-99
        495                                        // 100
    };

    public static int CalculateReadingScore(int rawScore)
    {
        if (rawScore <= 0) return 5;
        if (rawScore >= 100) return 495;
        return ReadingScale[rawScore];
    }
}
