# https://stackoverflow.com/a/21141788/16654916#comment-1
# http://www.icodeguru.com/webserver/Python-Programming-on-Win32/appd.htm
import sys
sys.coinit_flags = 0

import shutil
from threading import Thread
import win32com.client
import pythoncom

def run(file_path):
    pythoncom.CoInitialize()
    word = win32com.client.DispatchEx("Word.Application")
    word.Visible = False
    doc = word.Documents.Open(file_path)
    toc_count = doc.TablesOfContents.Count
    if toc_count == 1:
        print('update toc')
        toc = doc.TablesOfContents(1)
        toc.Update()
    doc.Close(SaveChanges=True)
    word.Quit()
    pythoncom.CoUninitialize()

for i in range(2):
    file_path = f'./example{i}.docx'
    shutil.copyfile('./example.docx', file_path)
    t = Thread(target=run, args=(file_path,))
    t.setDaemon(False)
    t.start()
