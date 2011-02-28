""" Common functions for notes management. """
import re

partspat = re.compile(r'([a-zA-Z][-_a-zA-Z]*)(\d+)')
refpat = re.compile(r'\[([a-zA-Z][-_a-zA-Z0-9]+)\]_')
impat = re.compile(r'^\s*..\s*image::\s*(\S+)',re.M)
colpat = re.compile(r'^:Color:\s*(\S+)',re.M|re.I)
stpat = re.compile(r'^:Status:\s*(\S+)',re.M|re.I)

def unique(list):
    """ Remove duplicates from a list. """
    return dict.fromkeys(list).keys()

def split(k):
    """ Get the 'base' and 'number' parts of a note. """  
    m = partspat.match(k)
    if m is None:
        return (k, 0)
    k,n = m.groups()
    return (k, int(n))

def cmpkey(k1, k2):
    """ Compare two note keys. """
    b1,n1 = split(k1)
    b2,n2 = split(k2)
    return cmp(b1, b2) or cmp(n1, n2)

class Repo(object):
    def __init__(self, validkeys=[]):
        self.d = dict.fromkeys(validkeys)

    def isnote(self, k):
        return self.d.has_key(k)

    def get(self, k):
        n = self.d.get(k)
        if n is None:
            f = file(k + '.txt')
            n = Note(k, f.read())
            f.close()
            self.d[k] = n
        return n

repo = None
            
def init_repo(validkeys):
    global repo
    repo = Repo(validkeys)

class Note(object):
    def __init__(self, k, contents=""):
        self.key = k
        self.contents = contents

    def get_deps(self):
        """ 
        Fetch the list of note keys referenced
        by this note. 
        """

        # Search all references
        matches = refpat.findall(self.contents)

        # Filter to return only real notes.
        l = []
        for d in matches:
            if repo.isnote(d) and d not in l:
                l.append(d)
        return l

    def get_imgs(self):
        """
        Fetch the list of image paths used
        by this note.
        """
        return impat.findall(self.contents)

    def get_status(self):
        """
        Fetch the status of the note.
        """
        m = stpat.search(self.contents)
        if m is None:
            return "UNSPECIFIED"
        return m.group(1).lower()

    def get_color(self):
        """
        Fetch the color of the note, or None if
        the note is not a book or doesn't have a color.
        """
        if not self.key.startswith('book'):
            return None
        m = colpat.search(self.contents)
        if m is None:
            return None
        return m.group(1)

def load(filename):
    return Note(file(filename).read())

