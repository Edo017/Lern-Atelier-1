int Num1;
int Num2;
int Result = 0;

Console.WriteLine("Geben Sie die 1. Zahl ein");
Num1 = Convert.ToInt32(Console.ReadLine());

Console.WriteLine("Geben Sie die 2. Zahl ein");
Num2 = Convert.ToInt32(Console.ReadLine());

Console.WriteLine("Möchten Sie die beiden Zahlen multiplizieren(m),addieren(a),subtrahieren(s) oder dividieren(d)?");
string input = Console.ReadLine();

if (input == "a")
{
    Result = Num1 + Num2;
}
else if(input == "m")
{
    Result = Num1 * Num2;
}
else if(input == "s")
{
    Result = Num1 - Num2;
}
else if(input == "d")
{
    Result = Num1 / Num2;
}
else
{
    Console.WriteLine("Fehlgeschlagen");
}
Console.WriteLine("Resultat ist " + Result);
Console.WriteLine("Vielen dank");
