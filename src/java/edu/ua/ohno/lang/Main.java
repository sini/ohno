package edu.ua.ohno.lang;

// CS 603: You do not need to edit this file.

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;
import java.io.*;

public class Main
{
    public static void main(String [] args) throws Exception {
        if (1 > args.length) {
            System.out.println("Usage: java edu.ua.ohno.lang.Main filename");
            System.exit(1);
        }
      try {
         for(String file : args) {
            // Create lexer for stdin
            System.out.println("Processing file: " + file);
            OhNoLexer lexer = new OhNoLexer(new ANTLRFileStream(file));
            OhNoParser parser = new OhNoParser(new CommonTokenStream(lexer));
            // Begin parsing at program, store return value
            OhNoParser.prog_return prog = parser.prog();
            if(parser.getNumberOfSyntaxErrors() > 0) {
               System.out.println("Parsing: failed");
            } else {
               System.out.println("Parsing: passed");
               Tree t = (Tree)prog.getTree();
               System.out.println("AST: " + t.toStringTree());
            }
         }
      } catch (IOException e) {
         System.out.println(e);
      }
    }
}
