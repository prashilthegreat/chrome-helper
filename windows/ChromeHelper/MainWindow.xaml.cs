using System.Diagnostics;
using System.IO;
using System.Text.Json;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;

namespace ChromeHelper;
public partial class MainWindow : Window
{
 const string Destination="https://admin.microsoft.com/"; readonly List<ChromeProfile> profiles=[];
 public MainWindow(){InitializeComponent();LoadProfiles();}
 void LoadProfiles(){try{var local=Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);var paths=new[]{Path.Combine(local,"Google","Chrome","User Data","Local State"),Path.Combine(local,"Google","Chrome Beta","User Data","Local State"),Path.Combine(local,"Google","Chrome SxS","User Data","Local State")};var path=paths.FirstOrDefault(File.Exists)??throw new FileNotFoundException("Google Chrome was not found.");using var json=JsonDocument.Parse(File.ReadAllText(path));foreach(var item in json.RootElement.GetProperty("profile").GetProperty("info_cache").EnumerateObject()){var name=item.Value.TryGetProperty("name",out var value)?value.GetString():item.Name;profiles.Add(new(name??item.Name,item.Name));}}catch(Exception e){MessageBox.Show(e.Message,"Chrome Helper",MessageBoxButton.OK,MessageBoxImage.Warning);}}
 void Plus_Click(object s,RoutedEventArgs e){HomeView.Visibility=Visibility.Collapsed;SearchView.Visibility=Visibility.Visible;ProfileInput.Clear();ResultsPanel.Children.Clear();ProfileInput.Focus();}
 void Find_Click(object s,RoutedEventArgs e)=>FindProfiles(); void ProfileInput_KeyDown(object s,KeyEventArgs e){if(e.Key==Key.Enter)FindProfiles();}
 void FindProfiles(){var query=ProfileInput.Text.Trim();var matches=profiles.Select(p=>new{Profile=p,Rank=Score(query,p.Name)}).Where(x=>x.Rank>=0).OrderByDescending(x=>x.Rank).ToList();ResultsPanel.Children.Clear();if(matches.Count==1){OpenProfile(matches[0].Profile);return;}if(matches.Count==0){ResultsPanel.Children.Add(new TextBlock{Text="No matching profiles found.",Foreground=Brushes.DimGray,TextAlignment=TextAlignment.Center,Margin=new(0,16,0,0)});return;}foreach(var match in matches){var button=new Button{Content=$"{match.Profile.Name}   ·   {match.Profile.Directory}",Tag=match.Profile,HorizontalContentAlignment=HorizontalAlignment.Left,Padding=new(10),Margin=new(0,0,0,6),Background=Brushes.White,Foreground=new SolidColorBrush(Color.FromRgb(23,32,24)),BorderBrush=new SolidColorBrush(Color.FromArgb(35,23,32,24)),Cursor=Cursors.Hand};button.Click+=(_,_)=>OpenProfile((ChromeProfile)button.Tag);ResultsPanel.Children.Add(button);}}
 static int Score(string query,string candidate){query=query.ToLowerInvariant();candidate=candidate.ToLowerInvariant();if(string.IsNullOrWhiteSpace(query))return-1;if(candidate==query)return 100;if(candidate.StartsWith(query))return 80-candidate.Length+query.Length;var contained=candidate.IndexOf(query,StringComparison.Ordinal);if(contained>=0)return 60-contained;var points=0;var cursor=0;foreach(var letter in query){var next=candidate.IndexOf(letter,cursor);if(next<0)return-1;points+=3-Math.Min(next-cursor,2);cursor=next+1;}return points;}
 void OpenProfile(ChromeProfile profile){try{var local=Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);var paths=new[]{Path.Combine(local,"Google","Chrome","Application","chrome.exe"),Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles),"Google","Chrome","Application","chrome.exe"),Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86),"Google","Chrome","Application","chrome.exe")};var chrome=paths.FirstOrDefault(File.Exists)??throw new FileNotFoundException("Chrome executable was not found.");Process.Start(new ProcessStartInfo(chrome,$"--profile-directory=\"{profile.Directory}\" \"{Destination}\""){UseShellExecute=true});BackToHome();}catch(Exception e){MessageBox.Show(e.Message,"Chrome Helper",MessageBoxButton.OK,MessageBoxImage.Error);}}
 void Back_Click(object s,RoutedEventArgs e)=>BackToHome();void BackToHome(){SearchView.Visibility=Visibility.Collapsed;HomeView.Visibility=Visibility.Visible;}void Close_Click(object s,RoutedEventArgs e)=>Close();void Window_MouseLeftButtonDown(object s,MouseButtonEventArgs e){if(e.ButtonState==MouseButtonState.Pressed)DragMove();}
}
public sealed record ChromeProfile(string Name,string Directory);
