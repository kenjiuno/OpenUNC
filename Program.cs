using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;

namespace OpenUNC {
    static class Program {
        /// <summary>
        /// アプリケーションのメイン エントリ ポイントです。
        /// </summary>
        [STAThread]
        static void Main(string[] args) {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            try {
                if (args.Length >= 1) {
                    Uri b = new Uri(Encoding.UTF8.GetString(Encoding.GetEncoding("latin1").GetBytes(args[0])));
                    if (String.Compare(b.Scheme, "unc") == 0 || String.Compare(b.Scheme, "file") == 0) {
                        String fp;
                        if (String.IsNullOrEmpty(b.Host) && Regex.IsMatch(b.LocalPath, "^[0-9a-fA-F]+$")) {
                            MemoryStream os = new MemoryStream();
                            String t = b.LocalPath;
                            for (int x = 0; x < t.Length; x += 2) {
                                os.WriteByte(Convert.ToByte(t.Substring(x, 2), 16));
                            }
                            fp = Encoding.UTF8.GetString(os.ToArray()).Replace("/", "\\");
                        }
                        else {
                            fp = "\\\\" + b.Host + "\\" + b.LocalPath.TrimStart('/').Replace('/', '\\');
                        }
                        using (WForm form = new WForm()) {
                            if (Environment.UserInteractive) {
                                form.lfp.Text = fp;
                                form.Show();
                                form.Update();
                            }

                            ProcessStartInfo psi = new ProcessStartInfo(fp);
                            psi.UseShellExecute = true;
                            Process p = Process.Start(psi);
                        }
                    }
                }
            }
            catch (Exception err) {
                if (Environment.UserInteractive) {
                    MessageBox.Show("失敗しました：" + err, Application.ProductName + " " + Application.ProductVersion, MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
                else {
                    Console.Error.WriteLine(err);
                }
                Environment.ExitCode = 1;
            }
        }
    }
}
