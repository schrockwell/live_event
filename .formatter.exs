# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  import_deps: [:phoenix_live_view],
  locals_without_parens: [
    assert_receive_event: 3,
    assert_receive_event: 4,
    assert_receive_event: 5,
    assert_received_event: 3,
    assert_received_event: 4,
    refute_receive_event: 3,
    refute_receive_event: 4,
    refute_receive_event: 5,
    refute_received_event: 3,
    refute_received_event: 4
  ],
  export: [
    locals_without_parens: [
      assert_receive_event: 3,
      assert_receive_event: 4,
      assert_receive_event: 5,
      assert_received_event: 3,
      assert_received_event: 4,
      refute_receive_event: 3,
      refute_receive_event: 4,
      refute_receive_event: 5,
      refute_received_event: 3,
      refute_received_event: 4
    ]
  ]
]
