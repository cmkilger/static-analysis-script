static-analysis-script is a Ruby script used as a build phase in Xcode to help find issues that Clang doesn't catch.

##Features

* Finds occurrences where an ivar is assigned an object with a +1 retain count. 

Example:
    self.string = [[NSString alloc] init];

##Usage

Copy the script into your project directory. Create a new Run Script build phase.  

    ./staticanalysis.rb $PROJECT_FILE_PATH $TARGETNAME 

##License

static-analysis-script is licensed under the MIT license, which is reproduced in its entirety here:

>Copyright (c) 2010 Cory Kilger
>
>Permission is hereby granted, free of charge, to any person obtaining a copy
>of this software and associated documentation files (the "Software"), to deal
>in the Software without restriction, including without limitation the rights
>to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
>copies of the Software, and to permit persons to whom the Software is
>furnished to do so, subject to the following conditions:
>
>The above copyright notice and this permission notice shall be included in
>all copies or substantial portions of the Software.
>
>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
>IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
>FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
>AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
>LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
>OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
>THE SOFTWARE.